{ config, inputs, ... }:
{
  flake.nixosConfigurations.nixos-test = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      ../../../hardware-configuration.nix
      { networking.hostName = "nixos-test"; }
      config.flake.modules.nixos.boot
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
