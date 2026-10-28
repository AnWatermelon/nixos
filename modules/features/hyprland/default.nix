{ config, lib, ... }:
let
  flakeCfg = config;
  keybindsContent = builtins.readFile ./configs/keybinds.lua;
in
{
  flake.modules.homeManager.hyprland =
    { config, ... }:
    let
      drmDevices = lib.concatMapStringsSep ":" (
        d: "/dev/dri/${d.name}-card"
      ) config.my.hardware.gpu.devices;
    in
    {
      imports = [
        ../desktop/options.nix
        ../hardware/options.nix
        flakeCfg.flake.modules.homeManager.scripts
      ];

      options.my.hyprland.displayConfig = lib.mkOption {
        type = lib.types.path;
        default = ./configs/displays.default.lua;
        description = "Path to lua file with monitor rules";
      };

      config.xdg.configFile = lib.mkIf (config.my.desktop.environment == "hyprland") {
        "hypr/hyprland.lua".source = ./hyprland.lua;
        "hypr/hyprtoolkit.conf".source = ./hyprtoolkit.conf;
        "hypr/configs/input.lua".source = ./configs/input.lua;
        "hypr/configs/looknfeel.lua".source = ./configs/looknfeel.lua;
        "hypr/configs/tags.lua".source = ./configs/tags.lua;
        "hypr/configs/UserAnimations.lua".source = ./configs/UserAnimations.lua;
        "hypr/configs/windowrules.lua".source = ./configs/windowrules.lua;
        "hypr/configs/keybinds.lua".text =
          builtins.replaceStrings
            [ ''terminal = "kitty"'' ''local browser = "zen"'' ]
            [
              ''terminal = "${lib.getExe config.my.terminal}"''
              ''local browser = "${config.my.desktop.browserCommand}"''
            ]
            keybindsContent;
        "hypr/configs/gpu.lua".text =
          lib.optionalString
            (config.my.hardware.gpu.configuration == "hybrid" && config.my.hardware.gpu.devices != [ ])
            ''
              hl.env("AQ_DRM_DEVICES", "${drmDevices}")
            '';
        "hypr/configs/display.lua".source = config.my.hyprland.displayConfig;
        "hypr/layouts".source = ./layouts;
      };
    };
}
