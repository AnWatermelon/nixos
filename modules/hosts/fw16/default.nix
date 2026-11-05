{
  config,
  inputs,
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

      (
        { lib, pkgs, ... }:
        {
          # see nix-cachyos-kernel-fw16 in flake.nix
          nixpkgs.overlays = lib.mkAfter [ inputs.nix-cachyos-kernel-fw16.overlays.pinned ];

          fileSystems."/home".neededForBoot = true;

          users.users.isabel = {
            isNormalUser = true;
            description = "Isabel";
            # only applies when the account is created; change it with passwd
            initialPassword = "changeme";
            extraGroups = [
              "networkmanager"
              "video"
            ];
            # Plasma's default browser, see the kde module
            packages = [
              pkgs.google-chrome
              inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.onlyoffice-desktopeditors
            ];
          };

          my = {
            dotfiles.live = true;
            kernel.cachyos = "bore-zen4";
            desktop = {
              browser = "zen";
              hyprland = {
                enable = true;
                displayConfig = ./displays.lua;
              };
              kde = {
                enable = true;
                defaultUser = "isabel";
              };
            };
            hardware = {
              laptop = true;
              powerDaemon = "ppd";
              gpu = {
                configuration = "hybrid";
                devices = [
                  {
                    name = "igpu";
                    pciId = "0000:c4:00.0";
                  }
                  {
                    name = "dgpu";
                    pciId = "0000:03:00.0";
                  }
                ];
                vendor = "amd";
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

      inputs.nixos-hardware.nixosModules.framework-16-7040-amd
    ];
  };
}
