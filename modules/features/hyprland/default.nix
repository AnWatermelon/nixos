{ config, ... }:
{
  flake.modules.homeManager.hyprland = {
    imports = [ config.flake.modules.homeManager.scripts ];

    xdg.configFile = {
      "hypr/hyprland.lua".source = ./hyprland.lua;
      "hypr/hyprtoolkit.conf".source = ./hyprtoolkit.conf;
      "hypr/configs".source = ./configs;
    };
  };
}
