{ config, lib, ... }:
let
  hyprlandLua = builtins.readFile ./hyprland.lua;
  hyprtoolkitConf = builtins.readFile ./hyprtoolkit.conf;
  inputLua = builtins.readFile ./configs/input.lua;
  keybindsLua = builtins.readFile ./configs/keybinds.lua;
  looknfeelLua = builtins.readFile ./configs/looknfeel.lua;
  tagsLua = builtins.readFile ./configs/tags.lua;
  userAnimationsLua = builtins.readFile ./configs/UserAnimations.lua;
  windowrulesLua = builtins.readFile ./configs/windowrules.lua;
  toggleAudioSh = builtins.readFile ./scripts/toggle_audio.sh;
in
{
  config.flake.modules.homeManager.hyprland = { inputs, lib, ... }: {
    imports = [
      config.flake.modules.homeManager.scripts
    ];
    wayland.windowManager.hyprland = {
      enable = true;
    };
    home.file = {
      ".config/hypr/hyprland.lua".text = hyprlandLua;
      ".config/hypr/hyprtoolkit.conf".text = hyprtoolkitConf;
      ".config/hypr/configs/input.lua".text = inputLua;
      ".config/hypr/configs/keybinds.lua".text = keybindsLua;
      ".config/hypr/configs/looknfeel.lua".text = looknfeelLua;
      ".config/hypr/configs/tags.lua".text = tagsLua;
      ".config/hypr/configs/UserAnimations.lua".text = userAnimationsLua;
      ".config/hypr/configs/windowrules.lua".text = windowrulesLua;
      ".config/hypr/scripts/toggle_audio.sh" = {
        text = toggleAudioSh;
        executable = true;
      };
    };
  };
}
