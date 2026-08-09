{ config, lib, ... }:
let
  flakeCfg = config;
  keybindsContent = builtins.readFile ./configs/keybinds.lua;
in
{
  flake.modules.homeManager.hyprland =
    { config, ... }:
    {
      imports = [ flakeCfg.flake.modules.homeManager.scripts ];

      xdg.configFile = lib.mkIf (config.my.desktop.environment == "hyprland") {
        "hypr/hyprland.lua".source = ./hyprland.lua;
        "hypr/hyprtoolkit.conf".source = ./hyprtoolkit.conf;
        "hypr/configs/input.lua".source = ./configs/input.lua;
        "hypr/configs/looknfeel.lua".source = ./configs/looknfeel.lua;
        "hypr/configs/tags.lua".source = ./configs/tags.lua;
        "hypr/configs/UserAnimations.lua".source = ./configs/UserAnimations.lua;
        "hypr/configs/windowrules.lua".source = ./configs/windowrules.lua;
        "hypr/configs/keybinds.lua".text =
          builtins.replaceStrings
            [ ''terminal = "kitty"'' ]
            [ ''terminal = "${lib.getExe config.my.terminal}"'' ]
            keybindsContent;
      };
    };
}
