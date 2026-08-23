{
  config,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.nixos-test = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      # Underscore prefix keeps import-tree from loading this NixOS module as a
      # flake-parts module.
      ./_hardware-configuration.nix
      ./_bootloader.nix
      config.flake.modules.nixos.terminal
      { networking.hostName = "nixos-test"; }
      {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = true;
            PermitRootLogin = "no";
          };
        };
      }

      config.flake.modules.nixos.boot
      config.flake.modules.nixos.networking
      config.flake.modules.nixos.locale
      config.flake.modules.nixos.audio
      config.flake.modules.nixos.xdg
      config.flake.modules.nixos.users
      config.flake.modules.nixos.core
      config.flake.modules.nixos.desktop

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
}
