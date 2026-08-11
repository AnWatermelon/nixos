{ config, lib, ... }:
let
  flakeCfg = config;
in
{
  flake.modules.homeManager.desktop =
    {
      pkgs,
      inputs,
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
        flakeCfg.flake.modules.homeManager.steam
        flakeCfg.flake.modules.homeManager.discord
        flakeCfg.flake.modules.homeManager.zen-browser
        flakeCfg.flake.modules.homeManager.hyprland
        flakeCfg.flake.modules.homeManager.niri
      ];
      config = {
        home.packages = (lib.optionals (cfg.environment == "hyprland") [ pkgs.hyprland ]) ++ [
          inputs.noctalia.packages.${pkgs.system}.default
        ];
      };
    };
}
