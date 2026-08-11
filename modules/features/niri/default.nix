{ config, lib, ... }:
let
  flakeCfg = config;
in
{
  flake.modules.homeManager.niri =
    { inputs, config, ... }:
    {
      imports = [
        ../desktop/options.nix
        inputs.niri.homeModules.niri
        flakeCfg.flake.modules.homeManager.scripts
      ];

      config = {
        programs.niri.enable = lib.mkIf (config.my.desktop.environment == "niri") true;

      programs.niri.settings = lib.mkIf (config.my.desktop.environment == "niri") {
        input = {
          keyboard = {
            numlock = true;
          };
          touchpad = {
            tap = true;
            natural-scroll = true;
          };
        };

        layout = {
          gaps = 16;
          center-focused-column = "never";
          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
          ];
          default-column-width = {
            proportion = 0.5;
          };

          focus-ring = {
            width = 4;
          };

          border = {
            enable = false;
            width = 4;
          };

          shadow = {
            softness = 30;
            spread = 5;
            offset.x = 0;
            offset.y = 5;
          };

        };

        spawn-at-startup = [
          { command = [ "noctalia" ]; }
        ];

        screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

        window-rules = [
          {
            matches = [ { app-id = "^kitty$"; } ];
            draw-border-with-background = false;
          }
          {
            matches = [ { app-id = "^org\\.wezfurlong\\.wezterm$"; } ];
            default-column-width = { };
          }
          {
            matches = [
              {
                app-id = "firefox$";
                title = "^Picture-in-Picture$";
              }
            ];
            open-floating = true;
          }
        ];

        binds = {
          "Mod+Shift+Slash".action."show-hotkey-overlay" = [ ];
          "Mod+T" = {
            hotkey-overlay.title = "Open a Terminal: ${config.my.terminal.pname}";
            action.spawn = lib.getExe config.my.terminal;
          };
          "Super+Alt+S" = {
            allow-when-locked = true;
            action.spawn-sh = "pkill orca || exec orca";
          };

          "XF86AudioPlay" = {
            allow-when-locked = true;
            action.spawn-sh = "playerctl play-pause";
          };
          "XF86AudioStop" = {
            allow-when-locked = true;
            action.spawn-sh = "playerctl stop";
          };
          "XF86AudioPrev" = {
            allow-when-locked = true;
            action.spawn-sh = "playerctl previous";
          };
          "XF86AudioNext" = {
            allow-when-locked = true;
            action.spawn-sh = "playerctl next";
          };
          "XF86AudioMicMute" = {
            allow-when-locked = true;
            action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          };

          "Mod+O" = {
            repeat = false;
            action."toggle-overview" = [ ];
          };
          "Mod+Q" = {
            repeat = false;
            action."close-window" = [ ];
          };

          "Mod+Left".action."focus-column-left" = [ ];
          "Mod+Down".action."focus-window-down" = [ ];
          "Mod+Up".action."focus-window-up" = [ ];
          "Mod+Right".action."focus-column-right" = [ ];

          "Mod+H".action."focus-column-left" = [ ];
          "Mod+J".action."focus-window-down" = [ ];
          "Mod+K".action."focus-window-up" = [ ];

          "Mod+Ctrl+H".action."move-column-left" = [ ];
          "Mod+Ctrl+J".action."move-window-down" = [ ];
          "Mod+Ctrl+K".action."move-window-up" = [ ];
          "Mod+Ctrl+L".action."move-column-right" = [ ];

          "Mod+Home".action."focus-column-first" = [ ];
          "Mod+End".action."focus-column-last" = [ ];
          "Mod+Ctrl+Home".action."move-column-to-first" = [ ];
          "Mod+Ctrl+End".action."move-column-to-last" = [ ];

          "Mod+Shift+H".action."focus-monitor-left" = [ ];
          "Mod+Shift+J".action."focus-monitor-down" = [ ];
          "Mod+Shift+K".action."focus-monitor-up" = [ ];
          "Mod+Shift+L".action."focus-monitor-right" = [ ];

          "Mod+Shift+Ctrl+Left".action."move-column-to-monitor-left" = [ ];
          "Mod+Shift+Ctrl+Down".action."move-column-to-monitor-down" = [ ];
          "Mod+Shift+Ctrl+Up".action."move-column-to-monitor-up" = [ ];
          "Mod+Shift+Ctrl+Right".action."move-column-to-monitor-right" = [ ];
          "Mod+Shift+Ctrl+H".action."move-column-to-monitor-left" = [ ];
          "Mod+Shift+Ctrl+J".action."move-column-to-monitor-down" = [ ];
          "Mod+Shift+Ctrl+K".action."move-column-to-monitor-up" = [ ];
          "Mod+Shift+Ctrl+L".action."move-column-to-monitor-right" = [ ];

          "Mod+Page_Down".action."focus-workspace-down" = [ ];
          "Mod+Page_Up".action."focus-workspace-up" = [ ];
          "Mod+U".action."focus-workspace-down" = [ ];
          "Mod+I".action."focus-workspace-up" = [ ];
          "Mod+Ctrl+Page_Down".action."move-column-to-workspace-down" = [ ];
          "Mod+Ctrl+Page_Up".action."move-column-to-workspace-up" = [ ];
          "Mod+Ctrl+U".action."move-column-to-workspace-down" = [ ];
          "Mod+Ctrl+I".action."move-column-to-workspace-up" = [ ];
          "Mod+Shift+Page_Down".action."move-workspace-down" = [ ];
          "Mod+Shift+Page_Up".action."move-workspace-up" = [ ];
          "Mod+Shift+U".action."move-workspace-down" = [ ];
          "Mod+Shift+I".action."move-workspace-up" = [ ];

          "Mod+WheelScrollDown" = {
            cooldown-ms = 150;
            action."focus-workspace-down" = [ ];
          };
          "Mod+WheelScrollUp" = {
            cooldown-ms = 150;
            action."focus-workspace-up" = [ ];
          };
          "Mod+Ctrl+WheelScrollDown" = {
            cooldown-ms = 150;
            action."move-column-to-workspace-down" = [ ];
          };
          "Mod+Ctrl+WheelScrollUp" = {
            cooldown-ms = 150;
            action."move-column-to-workspace-up" = [ ];
          };
          "Mod+WheelScrollRight".action."focus-column-right" = [ ];
          "Mod+WheelScrollLeft".action."focus-column-left" = [ ];
          "Mod+Ctrl+WheelScrollRight".action."move-column-right" = [ ];
          "Mod+Ctrl+WheelScrollLeft".action."move-column-left" = [ ];
          "Mod+Shift+WheelScrollDown".action."focus-column-right" = [ ];
          "Mod+Shift+WheelScrollUp".action."focus-column-left" = [ ];
          "Mod+Ctrl+Shift+WheelScrollDown".action."move-column-right" = [ ];
          "Mod+Ctrl+Shift+WheelScrollUp".action."move-column-left" = [ ];

          "Mod+1".action."focus-workspace" = 1;
          "Mod+2".action."focus-workspace" = 2;
          "Mod+3".action."focus-workspace" = 3;
          "Mod+4".action."focus-workspace" = 4;
          "Mod+5".action."focus-workspace" = 5;
          "Mod+6".action."focus-workspace" = 6;
          "Mod+7".action."focus-workspace" = 7;
          "Mod+8".action."focus-workspace" = 8;
          "Mod+9".action."focus-workspace" = 9;
          "Mod+Ctrl+1".action."move-column-to-workspace" = 1;
          "Mod+Ctrl+2".action."move-column-to-workspace" = 2;
          "Mod+Ctrl+3".action."move-column-to-workspace" = 3;
          "Mod+Ctrl+4".action."move-column-to-workspace" = 4;
          "Mod+Ctrl+5".action."move-column-to-workspace" = 5;
          "Mod+Ctrl+6".action."move-column-to-workspace" = 6;
          "Mod+Ctrl+7".action."move-column-to-workspace" = 7;
          "Mod+Ctrl+8".action."move-column-to-workspace" = 8;
          "Mod+Ctrl+9".action."move-column-to-workspace" = 9;

          "Mod+BracketLeft".action."consume-or-expel-window-left" = [ ];
          "Mod+BracketRight".action."consume-or-expel-window-right" = [ ];
          "Mod+Comma".action."consume-window-into-column" = [ ];
          "Mod+Period".action."expel-window-from-column" = [ ];
          "Mod+Shift+R".action."switch-preset-column-width-back" = [ ];
          "Mod+Ctrl+Shift+R".action."switch-preset-window-height" = [ ];
          "Mod+Ctrl+R".action."reset-window-height" = [ ];
          "Mod+Ctrl+C".action."center-visible-columns" = [ ];

          "Mod+Minus".action."set-column-width" = [ "-10%" ];
          "Mod+Equal".action."set-column-width" = [ "+10%" ];
          "Mod+Shift+Minus".action."set-window-height" = [ "-10%" ];
          "Mod+Shift+Equal".action."set-window-height" = [ "+10%" ];

          "Mod+Shift+V".action."switch-focus-between-floating-and-tiling" = [ ];

          "Print".action."screenshot" = [ ];
          "Ctrl+Print".action."screenshot-screen" = [ ];
          "Alt+Print".action."screenshot-window" = [ ];

          "Mod+Escape" = {
            allow-inhibiting = false;
            action."toggle-keyboard-shortcuts-inhibit" = [ ];
          };
          "Mod+Shift+E".action."quit" = [ ];
          "Mod+Shift+P".action."power-off-monitors" = [ ];

          "Ctrl+Alt+Delete".action.spawn-sh = "noctalia msg panel-toggle session";
          "Mod+E".action.spawn-sh = "kitty --hold -e zsh -i -c 'y'";
          "Mod+Space".action."toggle-window-floating" = [ ];
          "Mod+R".action.spawn-sh = "noctalia msg config-reload";
          "Mod+B".action.spawn = "zen-browser";
          "Mod+L".action.spawn-sh = "noctalia msg session lock";
          "Mod+Shift+S".action.spawn-sh = "noctalia msg screenshot-region";
          "Mod+W".action.spawn-sh = "noctalia msg panel-toggle wallpaper";
          "Mod+C".action.spawn = [
            "hyprpicker"
            "-a"
          ];
          "Mod+V".action.spawn-sh = "noctalia msg panel-open clipboard";
          "Mod+Z".action.spawn-sh = "noctalia msg panel-toggle control-center";
          "Mod+S".action.spawn-sh = "noctalia msg settings-toggle";
          "Mod+F".action."maximize-column" = [ ];
          "Mod+A".action.spawn-sh = "noctalia msg panel-open maxfh/noctagent:chat";
          "Mod+Shift+A".action.spawn-sh = "~/.config/scripts/toggle_audio.sh";
          "Ctrl+Shift+Escape".action.spawn-sh = "noctalia msg panel-toggle control-center system";

          "Mod+Shift+Left".action."swap-window-left" = [ ];
          "Mod+Shift+Right".action."swap-window-right" = [ ];
          "Mod+Shift+Up".action."move-window-up" = [ ];
          "Mod+Shift+Down".action."move-window-down" = [ ];

          "Mod+Ctrl+Left".action."set-column-width" = [ "-10%" ];
          "Mod+Ctrl+Right".action."set-column-width" = [ "+10%" ];
          "Mod+Ctrl+Up".action."set-window-height" = [ "+10%" ];
          "Mod+Ctrl+Down".action."set-window-height" = [ "-10%" ];

          "Mod+Shift+1".action."move-window-to-workspace" = 1;
          "Mod+Shift+2".action."move-window-to-workspace" = 2;
          "Mod+Shift+3".action."move-window-to-workspace" = 3;
          "Mod+Shift+4".action."move-window-to-workspace" = 4;
          "Mod+Shift+5".action."move-window-to-workspace" = 5;
          "Mod+Shift+6".action."move-window-to-workspace" = 6;
          "Mod+Shift+7".action."move-window-to-workspace" = 7;
          "Mod+Shift+8".action."move-window-to-workspace" = 8;
          "Mod+Shift+9".action."move-window-to-workspace" = 9;
          "Mod+Shift+0".action."move-window-to-workspace" = 10;

          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            action.spawn-sh = "noctalia msg volume-up";
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            action.spawn-sh = "noctalia msg volume-down";
          };
          "XF86AudioMute" = {
            allow-when-locked = true;
            action.spawn-sh = "noctalia msg volume-mute";
          };
          "XF86MonBrightnessUp" = {
            allow-when-locked = true;
            action.spawn-sh = "noctalia msg brightness-up";
          };
          "XF86MonBrightnessDown" = {
            allow-when-locked = true;
            action.spawn-sh = "noctalia msg brightness-down";
          };
        };
      };

      };
    };
}
