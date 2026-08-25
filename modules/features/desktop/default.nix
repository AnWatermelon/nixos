{
  config,
  lib,
  inputs,
  ...
}:
let
  flakeCfg = config;
  cfg = config.my.desktop;
in
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
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
      config = {
        home.packages = lib.optionals (cfg.environment == "hyprland") [ pkgs.hyprland ];
      };
    };
}
