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
            path = [
              pkgs.coreutils
              pkgs.git
              config.system.build.nixos-rebuild
            ];
            script = ''
              set -euo pipefail

              # The final switch replaces the minimal system, whose getty takes
              # over tty1 and hangs up the console session; ignore the hangup
              # so the trailing steps (locking root, reboot) still run. Also
              # ignore Ctrl-C: aborting mid-switch would leave a broken system
              # (stop it via systemctl instead).
              trap ''' HUP INT

              target="$(cat /etc/install-target)"
              say() { echo "install-finalize: $*"; }

              say "starting finalization: target host '$target'"
              say "live progress is on this console; it is also in the journal (journalctl -u install-finalize -f)"

              say "switching to host '$target' (the first switch downloads and builds; this can take a while)"
              switched=0
              for attempt in $(seq 1 10); do
                if nixos-rebuild switch --flake "/etc/nixos#$target"; then
                  switched=1
                  break
                fi
                say "switch failed (attempt $attempt/10); retrying in 60s"
                sleep 60
              done

              if [[ $switched -ne 1 ]]; then
                say "ERROR: switch failed after 10 attempts."
                say "Log in via SSH or on tty2 (Ctrl+Alt+F2), then run: sudo systemctl restart install-finalize"
                exit 1
              fi

              # Sync /etc/nixos history. This runs after the switch because
              # the shared Gitea host key is only available once the target
              # host's sops secrets are decrypted; hosts without the key
              # sync from the public GitHub mirror instead.
              sync_ok=1
              if ! git -C /etc/nixos rev-parse -q --verify HEAD >/dev/null 2>&1; then
                if [[ -f /etc/gitea/id_ed25519 ]]; then
                  sync_remote="origin"
                else
                  say "no Gitea host key on '$target'; syncing from the GitHub mirror"
                  sync_remote="github"
                fi
                say "syncing /etc/nixos with $sync_remote"
                sync_ok=0
                for attempt in $(seq 1 10); do
                  if timeout 120 git -C /etc/nixos fetch -q "$sync_remote"; then
                    rev="$(cat /etc/install-flake-rev 2>/dev/null || true)"
                    if [[ "$rev" =~ ^[0-9a-f]{7,64}$ ]] && git -C /etc/nixos fetch -q "$sync_remote" -- "$rev"; then
                      git -C /etc/nixos reset --quiet FETCH_HEAD
                    elif git -C /etc/nixos rev-parse -q --verify "$sync_remote/main" >/dev/null 2>&1; then
                      git -C /etc/nixos reset --quiet "$sync_remote/main"
                      say "warning: flake rev unavailable; /etc/nixos reset to $sync_remote/main"
                    else
                      say "warning: $sync_remote has no usable ref; /etc/nixos left as installed"
                      sync_ok=1
                    fi
                    git -C /etc/nixos branch --set-upstream-to="$sync_remote/main" main 2>/dev/null || true
                    sync_ok=1
                    break
                  fi
                  say "git sync failed (attempt $attempt/10); waiting for network"
                  sleep 30
                done
              fi

              say "switch complete; locking the root account"
              passwd -l root
              if [[ $sync_ok -ne 1 ]]; then
                say "warning: could not sync /etc/nixos with $sync_remote; it has no git history yet"
                say "warning: install-finalize will retry on the next boot; to fix now run:"
                say "warning:   git -C /etc/nixos fetch $sync_remote && git -C /etc/nixos reset --quiet $sync_remote/main"
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
