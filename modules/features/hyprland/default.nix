{ lib, inputs, ... }:
{
  flake.modules.nixos.hyprland =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.my.desktop.hyprland;
      gpu = config.my.hardware.gpu;
      drmDevices = lib.concatMapStringsSep ":" (d: "/dev/dri/${d.name}-card") gpu.devices;
    in
    {
      options.my.desktop.hyprland = {
        enable = lib.mkEnableOption "the Hyprland desktop";
        displayConfig = lib.mkOption {
          type = lib.types.path;
          default = ./configs/displays.default.lua;
          description = "Path to lua file with monitor rules";
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
        programs.hyprland = {
          enable = true;
          xwayland.enable = true;
          withUWSM = true;
        };
        xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

        my.dotfiles.files = {
          ".config/hypr/hyprland.lua".source = ./hyprland.lua;
          ".config/hypr/hyprtoolkit.conf".source = ./hyprtoolkit.conf;
          ".config/hypr/configs/input.lua".source = ./configs/input.lua;
          ".config/hypr/configs/looknfeel.lua".source = ./configs/looknfeel.lua;
          ".config/hypr/configs/tags.lua".source = ./configs/tags.lua;
          ".config/hypr/configs/UserAnimations.lua".source = ./configs/UserAnimations.lua;
          ".config/hypr/configs/windowrules.lua".source = ./configs/windowrules.lua;
          ".config/hypr/configs/keybinds.lua".source = ./configs/keybinds.lua;
          ".config/hypr/configs/display.lua".source = cfg.displayConfig;
          ".config/hypr/layouts".source = ./layouts;

          # Nix-computed values, one file per concern.
          ".config/hypr/nix/apps.lua".text = ''
            return {
              terminal = "${lib.getExe config.my.terminal}",
              browser = "${config.my.desktop.browserCommand}",
            }
          '';
          ".config/hypr/nix/gpu.lua".text =
            lib.optionalString (gpu.configuration == "hybrid" && gpu.devices != [ ])
              ''
                hl.env("AQ_DRM_DEVICES", "${drmDevices}")
              '';
        };
      };
    };
}
