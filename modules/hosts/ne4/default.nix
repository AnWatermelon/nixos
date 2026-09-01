{
  config,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.ne4 = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      ./_hardware-configuration.nix
      ./_bootloader.nix
      { networking.hostName = "ne4"; }
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
        my = {
          kernel.cachyos = "bore-zen4";
          desktop.environment = "hyprland";
          hardware = {
            laptop = false;
            gpu = {
              configuration = "dgpu";
              vendor = "nvidia";
            };
          };
        };
      }

      config.flake.modules.nixos.boot
      config.flake.modules.nixos.kernel
      config.flake.modules.nixos.networking
      config.flake.modules.nixos.netbird
      config.flake.modules.nixos.gitea
      config.flake.modules.nixos.locale
      config.flake.modules.nixos.audio
      config.flake.modules.nixos.users
      config.flake.modules.nixos.core
      config.flake.modules.nixos.desktop
      config.flake.modules.nixos.hardware
      config.flake.modules.nixos.terminal
      config.flake.modules.nixos.nas

      (
        { pkgs, ... }:
        {
          environment.systemPackages = [
            pkgs.libreoffice
            pkgs.nemo
          ];
        }
      )

      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          sharedModules = [
            ({ osConfig, ... }: {
              my.hardware = osConfig.my.hardware;
            })
          ];
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
