{
  config,
  inputs,
  lib,
  self,
  ...
}:
{
  flake.nixosConfigurations.iso = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      (
        {
          modulesPath,
          pkgs,
          ...
        }:
        {
          imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-base.nix") ];

          nixpkgs.hostPlatform = "x86_64-linux";
          boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
          boot.supportedFilesystems.zfs = lib.mkForce false;

          boot.postBootCommands = ''
            mount -o remount,size=20G,noatime /nix/.rw-store
          '';

          isoImage = {
            edition = "Max";
            contents = [
              {
                source = self;
                target = "/etc/nixos/flake";
              }
            ];
          };

          # installation-device.nix assigns the `nixos` user unconditionally.
          services.getty.autologinUser = lib.mkForce "maxfh";
          users.users.maxfh.initialPassword = "nixos";
        }
      )

      { networking.hostName = "iso"; }

      config.flake.modules.nixos.networking
      config.flake.modules.nixos.locale
      config.flake.modules.nixos.audio
      config.flake.modules.nixos.xdg
      config.flake.modules.nixos.users
      config.flake.modules.nixos.core
      config.flake.modules.nixos.hyprland

      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          users.maxfh.imports = [
            config.flake.modules.homeManager.base
            config.flake.modules.homeManager.cli
            config.flake.modules.homeManager.desktop
          ];
        };
      }
    ];
  };

  perSystem = _: {
    packages.iso = config.flake.nixosConfigurations.iso.config.system.build.isoImage;
  };
}
