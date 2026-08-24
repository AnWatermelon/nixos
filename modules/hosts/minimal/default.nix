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

              if ! git -C /etc/nixos rev-parse -q --verify HEAD >/dev/null 2>&1; then
                say "syncing /etc/nixos with GitHub"
                synced=0
                for attempt in $(seq 1 10); do
                  if timeout 120 git -C /etc/nixos fetch -q origin; then
                    rev="$(cat /etc/install-flake-rev 2>/dev/null || true)"
                    if [[ -n "$rev" ]] && git -C /etc/nixos fetch -q origin "$rev"; then
                      git -C /etc/nixos reset --quiet FETCH_HEAD
                    else
                      git -C /etc/nixos reset --quiet origin/main
                      say "warning: flake rev unavailable; /etc/nixos reset to origin/main"
                    fi
                    git -C /etc/nixos branch --set-upstream-to=origin/main main || true
                    synced=1
                    break
                  fi
                  say "git sync failed (attempt $attempt/10); waiting for network"
                  sleep 30
                done
                if [[ $synced -ne 1 ]]; then
                  say "warning: could not reach GitHub; using the flake as installed"
                fi
              fi

              # Ensure pushes to /etc/nixos go to the private Gitea mirror via
              # the shared host key (fetches stay on the public GitHub mirror).
              if ! git -C /etc/nixos remote set-url --push origin gitea@gitea.hilton-tech.net:max_hilton/nixos.git; then
                say "warning: could not set gitea push URL for /etc/nixos"
              fi

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

              say "switch complete; locking the root account"
              passwd -l root
              touch /var/lib/install-finalize.done
              say "installation finalized: this system will now reboot"
              reboot
            '';
          };
        }
      )
    ];
  };
}
