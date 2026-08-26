{
  config,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.minimal = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      ./_hardware-configuration.nix
      ./_bootloader.nix
      { networking.hostName = "minimal"; }

      {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = true;
            PermitRootLogin = "no";
          };
        };
      }

      config.flake.modules.nixos.networking
      config.flake.modules.nixos.locale
      config.flake.modules.nixos.users
      config.flake.modules.nixos.core

      (
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          users.users.root.initialPassword = "nixos";
          users.users.maxfh.initialPassword = "nixos";

          # tty1 belongs to install-finalize's live progress output; no login
          # prompt during the minimal phase. logind still spawns a getty on
          # the other VTs when they are switched to, and sshd is enabled, so
          # the machine stays reachable for debugging.
          systemd.targets.getty.wants = lib.mkForce [ ];

          systemd.services.install-finalize = {
            description = "Finalize installation by switching to the target host";
            wantedBy = [ "multi-user.target" ];
            unitConfig.ConditionPathExists = [
              "/etc/install-target"
              "!/var/lib/install-finalize.done"
            ];
            # This unit only exists on the minimal host, so it disappears from
            # the target host's unit set. Without this, switch-to-configuration
            # would stop us mid-run while we are performing the switch.
            unitConfig.X-StopOnRemoval = false;
            serviceConfig = {
              # Start when boot has finished and take over tty1 so that every
              # action (git sync, nixos-rebuild, ...) streams to the console.
              Type = "idle";
              RemainAfterExit = true;
              StandardInput = "tty";
              StandardOutput = "journal+console";
              StandardError = "journal+console";
              TTYPath = "/dev/tty1";
              TTYReset = "yes";
              TTYVHangup = "yes";
            };
            # git fetch of the Gitea origin needs the ssh client;
            # nixos-generate-config regenerates the install-time generated
            # configs after any /etc/nixos tree reset.
            path = [
              pkgs.coreutils
              pkgs.gnused
              pkgs.git
              pkgs.openssh
              pkgs.util-linux
              pkgs.nixos-install-tools
              config.system.build.nixos-rebuild
            ];
            script = ''
              set -euo pipefail

              # The final switch replaces the minimal system, whose getty takes
              # over tty1 and hangs up the console session; ignore the hangup
              # so the trailing steps (root-lock marker, reboot) still run.
              # Also ignore Ctrl-C: aborting mid-switch would leave a broken
              # system (stop it via systemctl instead).
              trap ''' HUP INT

              target="$(cat /etc/install-target)"
              say() { echo "install-finalize: $*"; }

              # ssh must never prompt on the console: on the minimal host the
              # Gitea origin has no key yet, and a host-key prompt on tty1
              # would hang until the fetch times out.
              export GIT_SSH_COMMAND="ssh -o BatchMode=yes"

              say "starting finalization: target host '$target'"
              say "live progress is on this console; it is also in the journal (journalctl -u install-finalize -f)"

              # Fetch the remote history (Gitea origin, falling back to the
              # public GitHub mirror) and reset the tree to it. --hard is
              # deliberate: a mixed reset would leave the installed files in
              # place, so a broken flake baked into the ISO would never be
              # replaced by the fixed one on the remote. The generated configs
              # are restored by regenerate_configs below.
              # Sets SYNC_REMOTE to the remote that worked, or empties it.
              SYNC_REMOTE=""
              sync_etc_nixos() {
                local prefer_rev="$1"
                local attempt remote rev
                for attempt in $(seq 1 10); do
                  for remote in origin github; do
                    if timeout 120 git -C /etc/nixos fetch -q "$remote"; then
                      rev=""
                      if [[ "$prefer_rev" == "1" ]]; then
                        rev="$(cat /etc/install-flake-rev 2>/dev/null || true)"
                      fi
                      if [[ "$rev" =~ ^[0-9a-f]{7,64}$ ]] && git -C /etc/nixos fetch -q "$remote" -- "$rev"; then
                        git -C /etc/nixos reset --hard FETCH_HEAD
                        say "/etc/nixos reset to flake rev $rev from $remote"
                      elif git -C /etc/nixos rev-parse -q --verify "$remote/main" >/dev/null 2>&1; then
                        git -C /etc/nixos reset --hard "$remote/main"
                        say "warning: flake rev unavailable; /etc/nixos reset to $remote/main"
                      else
                        say "warning: $remote has no usable ref; trying the next remote"
                        continue
                      fi
                      git -C /etc/nixos branch --set-upstream-to="$remote/main" main 2>/dev/null || true
                      SYNC_REMOTE="$remote"
                      return 0
                    fi
                  done
                  say "git sync failed (attempt $attempt/10); waiting for network"
                  sleep 30
                done
                SYNC_REMOTE=""
                return 1
              }

              # The generated _hardware-configuration.nix and _bootloader.nix
              # files only ever exist as uncommitted local changes (the repo
              # carries placeholders), so any tree reset -- even a manual one
              # -- loses them. Regenerate them from the live system, which is
              # the same machine with the mounts the installer created.
              # Mirrors install-host.sh: the target's hardware config is only
              # regenerated when the install did not use --keep-hardware.
              regenerate_configs() {
                [[ -d /etc/nixos/modules/hosts/"$target" ]] || {
                  say "ERROR: no host '$target' in /etc/nixos"
                  exit 1
                }
                say "regenerating hardware configuration and bootloader"
                nixos-generate-config --root / --show-hardware-config | sed '/systemd-boot/d' \
                  > /etc/nixos/modules/hosts/minimal/_hardware-configuration.nix
                if [[ -f /etc/install-keep-hardware ]]; then
                  say "--keep-hardware install: preserving '$target' hardware configuration"
                else
                  cp /etc/nixos/modules/hosts/minimal/_hardware-configuration.nix \
                    /etc/nixos/modules/hosts/"$target"/_hardware-configuration.nix
                fi
                local bootloader
                if [[ -d /sys/firmware/efi ]]; then
                  bootloader='{ boot.loader.grub = { enable = true; efiSupport = true; efiInstallAsRemovable = true; device = "nodev"; }; }'
                else
                  printf -v bootloader '{ boot.loader.grub = { enable = true; device = "%s"; }; }' \
                    "$(cat /etc/install-disk 2>/dev/null || echo UNKNOWN-DISK)"
                fi
                printf '%s\n' "$bootloader" > /etc/nixos/modules/hosts/minimal/_bootloader.nix
                printf '%s\n' "$bootloader" > /etc/nixos/modules/hosts/"$target"/_bootloader.nix
              }

              [[ -d /etc/nixos/modules/hosts/"$target" ]] || {
                say "ERROR: no host '$target' in /etc/nixos"
                exit 1
              }

              # 1. Sync before the switch. This is what lets a broken baked
              #    tree self-heal, and it gives /etc/nixos its git history.
              #    Gitea needs the target's SSH key, which only exists after
              #    the switch, so the GitHub mirror is the fallback that works
              #    during the minimal phase.
              synced=1
              if ! git -C /etc/nixos rev-parse -q --verify HEAD >/dev/null 2>&1; then
                if sync_etc_nixos 1; then
                  say "synced /etc/nixos with $SYNC_REMOTE"
                else
                  synced=0
                  say "warning: could not sync /etc/nixos; using the tree installed by the ISO"
                fi
              else
                say "/etc/nixos already has git history; leaving the tree as-is"
              fi

              # 2. Always regenerate: the sync above (or any earlier reset)
              #    replaced the install-time generated configs with the repo's
              #    placeholders.
              regenerate_configs

              # 3. Switch, retrying up to 10 times. If the recorded flake rev
              #    keeps failing to build, drop the pin once and retry against
              #    the remote's main in case the rev predates a fix. The pin is
              #    only dropped after two consecutive failures so a transient
              #    failure (network hiccup, interrupted build) does not unpin
              #    the rev the ISO was built and tested with.
              say "switching to host '$target' (the first switch downloads and builds; this can take a while)"
              switched=0
              fallback_done=0
              for attempt in $(seq 1 10); do
                if nixos-rebuild switch --flake "/etc/nixos#$target"; then
                  switched=1
                  break
                fi
                say "switch failed (attempt $attempt/10)"
                if [[ $attempt -ge 2 && $fallback_done -eq 0 && -n "$SYNC_REMOTE" ]] \
                  && git -C /etc/nixos rev-parse -q --verify "$SYNC_REMOTE/main" >/dev/null 2>&1; then
                  fallback_done=1
                  say "retrying against $SYNC_REMOTE/main in case the recorded rev predates a fix"
                  git -C /etc/nixos reset --hard "$SYNC_REMOTE/main"
                  regenerate_configs
                fi
                sleep 60
              done

              if [[ $switched -ne 1 ]]; then
                say "ERROR: switch failed after 10 attempts."
                say "Log in via SSH or on tty2 (Ctrl+Alt+F2), then run: sudo systemctl restart install-finalize"
                exit 1
              fi

              # 4. The switch activated the target host, so its sops secrets
              #    are decrypted and the Gitea origin now authenticates. Make
              #    origin the upstream so 'git pull'/'git push' use the write
              #    remote; the GitHub mirror only works for pulls.
              if git -C /etc/nixos rev-parse -q --verify HEAD >/dev/null 2>&1 \
                && timeout 120 git -C /etc/nixos fetch -q origin \
                && git -C /etc/nixos rev-parse -q --verify origin/main >/dev/null 2>&1; then
                git -C /etc/nixos branch --set-upstream-to=origin/main main 2>/dev/null || true
                say "/etc/nixos upstream set to origin/main"
              fi

              # If the pre-switch sync failed (no network on the minimal
              # host), retry now: the origin may work post-switch. The reset
              # is --hard again, so restore the generated configs afterwards.
              if [[ $synced -ne 1 ]]; then
                if sync_etc_nixos 1; then
                  synced=1
                  regenerate_configs
                fi
              fi

              # 5. Leave a marker for the target host: a first-boot unit locks
              #    the root account once the final system has booted
              #    successfully at least once, so a broken final boot still
              #    leaves an emergency-console login path open.
              say "switch complete; leaving the root-lock marker for '$target'"
              touch /etc/root-lock-pending

              if [[ $synced -ne 1 ]]; then
                say "warning: could not sync /etc/nixos with a remote; it has no git history yet"
                say "warning: sync it manually once the network is back:"
                say "warning:   git -C /etc/nixos fetch origin && git -C /etc/nixos reset --hard origin/main"
              else
                touch /var/lib/install-finalize.done
              fi
              say "installation finalized: this system will now reboot"
              reboot
            '';
          };
        }
      )
    ];
  };
}
