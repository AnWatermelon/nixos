{
  lib,
  inputs,
  ...
}:
{
  flake.modules.nixos.desktop =
    { pkgs, config, ... }:
    let
      cfg = config.my.desktop;
    in
    {
      imports = [
        ./options.nix
        inputs.self.modules.nixos.steam
        inputs.self.modules.nixos.vivaldi
        inputs.self.modules.nixos.zen-browser
        inputs.self.modules.nixos.obs
        inputs.self.modules.nixos.greetd
        inputs.self.modules.nixos.xdg
        inputs.self.modules.nixos.flatpak
        inputs.self.modules.nixos.scripts
        inputs.self.modules.nixos.kitty
        inputs.self.modules.nixos.ghostty
        inputs.self.modules.nixos.hyprland
        inputs.self.modules.nixos.noctalia
      ];

      config = lib.mkMerge [
        {
          environment.systemPackages = with pkgs; [
            config.my.terminal
            lunar-client
            heroic
            gale
            prusa-slicer
            antigravity-ide
            spotify-player
            electrum
            libreoffice
            obs-studio
            godot
          ];
        }
        {
          programs.dconf.enable = true;
          services = {
            gvfs.enable = true;
            udisks2.enable = true;
          };
        }
        (lib.mkIf (cfg.environment == "hyprland") {
          environment.systemPackages = [
            inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
          programs.hyprland = {
            enable = true;
            xwayland.enable = true;
            withUWSM = true;
          };
          services.greetd.enable = lib.mkForce true;
          xdg.portal.extraPortals = [
            pkgs.xdg-desktop-portal-hyprland
          ];
        })
        (lib.mkIf (cfg.environment == "gnome") {
          services = {
            displayManager.gdm.enable = true;
            desktopManager.gnome.enable = true;
          };
          xdg.portal.extraPortals = [
            pkgs.xdg-desktop-portal-gtk
          ];
        })
      ];
    };
  flake.modules.homeManager.desktop =
    {
      pkgs,
      lib,
      config,
      osConfig,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      # Transitional: browser modules now live on the NixOS side.
      my.desktop.browserCommand = osConfig.my.desktop.browserCommand;

      # Transitional: niri and nemo still read the terminal from HM.
      my.terminal = osConfig.my.terminal;

      imports = [
        ./options.nix
        ../hardware/options.nix # transitional: hosts still forward my.hardware
        {
          options.my.terminal = lib.mkOption {
            type = lib.types.package;
            description = "Default terminal";
          };
        }
        inputs.self.modules.homeManager.discord
        inputs.self.modules.homeManager.niri
        inputs.self.modules.homeManager.nemo
      ];

      gtk = {
        enable = true;
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
      };

      home.packages = lib.optionals (cfg.environment == "hyprland") [ pkgs.hyprland ];

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adw-gtk3-dark";
        };
      };
    };
}
