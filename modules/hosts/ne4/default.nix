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
          dotfiles.live = true;
          kernel.cachyos = "bore-zen4";
          desktop.hyprland.enable = true;
          desktop.hyprland.displayConfig = ./display.lua;
          hardware = {
            laptop = false;
            gpu = {
              configuration = "dgpu";
              vendor = "amd";
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
      config.flake.modules.nixos.cli
      config.flake.modules.nixos.hardware
      config.flake.modules.nixos.terminal
      config.flake.modules.nixos.nas
      config.flake.modules.nixos.u2f
    ];
  };
}
