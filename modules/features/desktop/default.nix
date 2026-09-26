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
        inputs.self.modules.nixos.greetd
        inputs.self.modules.nixos.xdg
      ];

      config = lib.mkMerge [
        {
          environment.systemPackages = [
            pkgs.lunar-client
            pkgs.heroic
            pkgs.gale
            pkgs.prusa-slicer
            pkgs.antigravity-ide
            pkgs.spotify-player
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
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      imports = [
        ./options.nix
        inputs.self.modules.homeManager.terminal
        inputs.self.modules.homeManager.discord
        inputs.self.modules.homeManager.zen-browser
        inputs.self.modules.homeManager.hyprland
        inputs.self.modules.homeManager.niri
        inputs.self.modules.homeManager.noctalia
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
