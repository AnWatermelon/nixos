{ config, inputs, self, lib, ... }:
{
  flake.nixosConfigurations.iso = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ({ modulesPath, pkgs, ... }:
        let
          flakeSource = self.outPath;
        in
        {
          imports = [
            (modulesPath + "/image/images.nix")
          ];
          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          image.modules.iso = { modulesPath, pkgs, ... }: {
            imports = [
              (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
            ];
            isoImage = {
              makeEfiBootable = true;
              makeUsbBootable = true;
              edition = "Max";
              contents = [{
                source = flakeSource;
                target = "/etc/nixos/flake";
              }];
            };
            boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
            users.users."maxfh" = {
              initialPassword = "nixos";
            };
            services.getty.autologinUser = lib.mkDefault "maxfh";
          };
        })

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
          users.maxfh = {
            imports = [
              config.flake.modules.homeManager.base
              config.flake.modules.homeManager.zsh
              config.flake.modules.homeManager.kitty
              config.flake.modules.homeManager.git
              config.flake.modules.homeManager.ssh
              config.flake.modules.homeManager.cli
              config.flake.modules.homeManager.neovim
              config.flake.modules.homeManager.scripts
              config.flake.modules.homeManager.hyprland
            ];
          };
        };
      }
    ];
  };
}
