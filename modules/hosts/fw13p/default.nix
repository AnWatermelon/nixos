{
  config,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.fw13p = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      ./_hardware-configuration.nix
      ./_bootloader.nix
      ./_fprint-wake.nix
      config.flake.modules.nixos.terminal
      { networking.hostName = "fw13p"; }
      {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            PermitRootLogin = "no";
          };
        };
      }

      config.flake.modules.nixos.boot
      config.flake.modules.nixos.networking
      config.flake.modules.nixos.netbird
      config.flake.modules.nixos.locale
      config.flake.modules.nixos.audio
      config.flake.modules.nixos.fprint
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
