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
        id: "/dev/dri/by-path/pci-${id}-card"
      ) config.my.hardware.gpuPciIds;
    in
    {
      imports = [
        ../desktop/options.nix
        ../hardware/options.nix
        flakeCfg.flake.modules.homeManager.scripts
      ];

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
            [ ''terminal = "kitty"'' ]
            [ ''terminal = "${lib.getExe config.my.terminal}"'' ]
            keybindsContent;
        "hypr/configs/gpu.lua".text =
          lib.optionalString (config.my.hardware.gpu == "hybrid" && config.my.hardware.gpuPciIds != [ ])
            ''
              hl.env("AQ_DRM_DEVICES", "${drmDevices}")
            '';
      };
    };
}
