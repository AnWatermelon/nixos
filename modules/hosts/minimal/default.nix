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
          pkgs,
          ...
        }:
        {
          users.users.root.initialPassword = "nixos";
          users.users.maxfh.initialPassword = "nixos";

          systemd.services.install-finalize = {
            description = "Finalize installation by switching to the target host";
            wantedBy = [ "multi-user.target" ];
            unitConfig.ConditionPathExists = [
              "/etc/install-target"
              "!/var/lib/install-finalize.done"
            ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            path = [
              pkgs.coreutils
              pkgs.git
              config.system.build.nixos-rebuild
            ];
            script = ''
              set -euo pipefail

              target="$(cat /etc/install-target)"
              say() { echo "install-finalize: $*" | tee /dev/console >&2; }

              say "starting finalization: target host '$target'"
              say "progress: journalctl -u install-finalize -f"

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
                say "Connect the machine to the network, then run: sudo systemctl restart install-finalize"
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
