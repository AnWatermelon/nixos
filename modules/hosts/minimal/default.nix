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
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            unitConfig.ConditionPathExists = "!/var/lib/install-finalize.done";
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            path = [
              pkgs.git
              config.system.build.nixos-rebuild
            ];
            script = ''
              set -euo pipefail
              target="$(cat /etc/install-target)"

              if ! git -C /etc/nixos rev-parse -q --verify HEAD >/dev/null 2>&1; then
                echo "install-finalize: syncing /etc/nixos with GitHub"
                if git -C /etc/nixos fetch -q origin; then
                  rev="$(cat /etc/install-flake-rev 2>/dev/null || true)"
                  if [[ -n "$rev" ]] && git -C /etc/nixos fetch -q origin "$rev"; then
                    git -C /etc/nixos reset --quiet FETCH_HEAD
                  else
                    git -C /etc/nixos reset --quiet origin/main
                    echo "install-finalize: warning: flake rev unavailable; /etc/nixos reset to origin/main" >&2
                  fi
                  git -C /etc/nixos branch --set-upstream-to=origin/main main || true
                else
                  echo "install-finalize: warning: could not reach GitHub; /etc/nixos has no git history yet" >&2
                fi
              fi

              echo "install-finalize: switching to host '$target'"
              nixos-rebuild switch --flake "/etc/nixos#$target"
              passwd -l root
              touch /var/lib/install-finalize.done
            '';
          };
        }
      )
    ];
  };
}
