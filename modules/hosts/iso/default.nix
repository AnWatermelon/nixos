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
          # The installer profile enables ZFS, which has no module for the
          # latest kernel. Nothing here installs to ZFS.
          boot.supportedFilesystems.zfs = lib.mkForce false;

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
            config.flake.modules.homeManager.terminal
            config.flake.modules.homeManager.zsh
            config.flake.modules.homeManager.kitty
            config.flake.modules.homeManager.git
            config.flake.modules.homeManager.ssh
            config.flake.modules.homeManager.cli
            config.flake.modules.homeManager.neovim
            config.flake.modules.homeManager.hyprland
          ];
        };
      }
    ];
  };

  perSystem = _: {
    packages.iso = config.flake.nixosConfigurations.iso.config.system.build.isoImage;
  };
}
