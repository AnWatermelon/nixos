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

          systemd.targets.getty.wants = lib.mkForce [ ];

          systemd.services.install-finalize = {
            description = "Finalize installation by switching to the target host";
            wantedBy = [ "multi-user.target" ];
            unitConfig.ConditionPathExists = [
              "/etc/install-target"
              "!/var/lib/install-finalize.done"
            ];
            unitConfig.X-StopOnRemoval = false;
            serviceConfig = {
              Type = "idle";
              RemainAfterExit = true;
              StandardInput = "tty";
              StandardOutput = "journal+console";
              StandardError = "journal+console";
              TTYPath = "/dev/tty1";
              TTYReset = "yes";
              TTYVHangup = "yes";
            };
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

              trap ''' HUP INT

              target="$(cat /etc/install-target)"
              say() { echo "install-finalize: $*"; }

              export GIT_SSH_COMMAND="ssh -o BatchMode=yes"

              say "starting finalization: target host '$target'"
              say "live progress is on this console; it is also in the journal (journalctl -u install-finalize -f)"

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

              regenerate_configs

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

              if git -C /etc/nixos rev-parse -q --verify HEAD >/dev/null 2>&1 \
                && timeout 120 git -C /etc/nixos fetch -q origin \
                && git -C /etc/nixos rev-parse -q --verify origin/main >/dev/null 2>&1; then
                git -C /etc/nixos branch --set-upstream-to=origin/main main 2>/dev/null || true
                say "/etc/nixos upstream set to origin/main"
              fi

              if [[ $synced -ne 1 ]]; then
                if sync_etc_nixos 1; then
                  synced=1
                  regenerate_configs
                fi
              fi

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
