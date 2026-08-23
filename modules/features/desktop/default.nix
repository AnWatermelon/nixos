{ config, lib, inputs, ... }:
let
  flakeCfg = config;
in
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      imports = [ flakeCfg.flake.modules.nixos.steam ];

      environment.systemPackages = [
        inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
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
