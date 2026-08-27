{
  config,
  lib,
  inputs,
  ...
}:
let
  flakeCfg = config;
in
{
  flake.modules.nixos.desktop =
    { pkgs, config, ... }:
    let
      cfg = config.my.desktop;
    in
    {
      imports = [
        ./options.nix
        flakeCfg.flake.modules.nixos.steam
      ];

      config = lib.mkMerge [
        {
          environment.systemPackages = [
            inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
          ];
        }
        {
          programs.dconf.enable = true;
        }
        (lib.mkIf (cfg.environment == "hyprland") {
          programs.hyprland = {
            enable = true;
            xwayland.enable = true;
          };
        })
        (lib.mkIf (cfg.environment == "gnome") {
          services = {
            displayManager.gdm.enable = true;
            desktopManager.gnome.enable = true;
          };
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
        flakeCfg.flake.modules.homeManager.terminal
        flakeCfg.flake.modules.homeManager.discord
        flakeCfg.flake.modules.homeManager.zen-browser
        flakeCfg.flake.modules.homeManager.hyprland
        flakeCfg.flake.modules.homeManager.niri
        flakeCfg.flake.modules.homeManager.noctalia
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
