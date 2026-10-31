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

      (
        { pkgs, ... }:
        {
          my = {
            dotfiles.live = true;
            kernel.cachyos = "bore-x86_64-v3";
            desktop.environment = "hyprland";
            hyprland.displayConfig = ./displays.lua;
            hardware = {
              laptop = true;
              powerDaemon = "ppd";
              gpu = {
                configuration = "igpu";
                vendor = "intel";
              };
            };
            terminal = pkgs.kitty;
          };
        }
      )

      config.flake.modules.nixos.boot
      config.flake.modules.nixos.kernel
      config.flake.modules.nixos.networking
      config.flake.modules.nixos.netbird
      config.flake.modules.nixos.gitea
      config.flake.modules.nixos.locale
      config.flake.modules.nixos.audio
      config.flake.modules.nixos.fprint
      config.flake.modules.nixos.users
      config.flake.modules.nixos.core
      config.flake.modules.nixos.desktop
      config.flake.modules.nixos.cli
      config.flake.modules.nixos.hardware
      config.flake.modules.nixos.terminal
      config.flake.modules.nixos.nas
      config.flake.modules.nixos.u2f

      inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3
    ];
  };
}
