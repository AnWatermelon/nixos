{
  config,
  inputs,
  pkgs,
  ...
}:
{
  flake.nixosConfigurations.fw16 = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      ./_hardware-configuration.nix
      ./_bootloader.nix
      { networking.hostName = "fw16"; }
      {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            PermitRootLogin = "no";
          };
        };
      }

      {
        my.desktop.environment = "gnome";
      }

      config.flake.modules.nixos.boot
      config.flake.modules.nixos.networking
      config.flake.modules.nixos.netbird
      config.flake.modules.nixos.gitea
      config.flake.modules.nixos.locale
      config.flake.modules.nixos.audio
      config.flake.modules.nixos.fprint
      config.flake.modules.nixos.xdg
      config.flake.modules.nixos.users
      config.flake.modules.nixos.core
      config.flake.modules.nixos.desktop
      config.flake.modules.nixos.terminal

      {
        environment.systemPackages = [ pkgs.libreoffice ];
      }

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
