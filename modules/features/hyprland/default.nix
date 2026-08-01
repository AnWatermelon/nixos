{ config, lib, ... }:
{
  config.flake.modules.homeManager.hyprland = { inputs, lib, ... }: {
    imports = [
      config.flake.modules.homeManager.scripts
    ];
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$mod" = "SUPER";

        exec-once = [ "noctalia" ];

        input = {
          numlock_by_default = true;
          touchpad.natural_scroll = true;
        };

        general = {
          gaps_out = 16;
        };

        bind = [
          "$mod, T, exec, kitty"
          "$mod, Q, killactive"
          "$mod, B, exec, zen-browser"
          "$mod, E, exec, kitty --hold -e zsh -i -c 'y'"
          "$mod, Space, togglefloating"
          "$mod, F, fullscreen"
          "$mod SHIFT, A, exec, ~/.config/scripts/toggle_audio.sh"
          "$mod, L, exec, noctalia msg session lock"
          "$mod, R, exec, noctalia msg config-reload"
          "$mod, W, exec, noctalia msg panel-toggle wallpaper"
          "$mod, C, exec, hyprpicker -a"
          "$mod, V, exec, noctalia msg panel-open clipboard"
          "$mod, Z, exec, noctalia msg panel-toggle control-center"
          "$mod, S, exec, noctalia msg settings-toggle"
          "$mod SHIFT, S, exec, noctalia msg screenshot-region"
          "CTRL ALT, Delete, exec, noctalia msg panel-toggle session"
          "CTRL SHIFT, Escape, exec, noctalia msg panel-toggle control-center system"
          "SUPER ALT, S, exec, pkill orca || exec orca"

          # Navigation
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, L, movewindow, r"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, J, movewindow, d"

          # Workspaces
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"

          # Resize
          "$mod CTRL, H, resizeactive, -30 0"
          "$mod CTRL, L, resizeactive, 30 0"
          "$mod CTRL, K, resizeactive, 0 -30"
          "$mod CTRL, J, resizeactive, 0 30"

          # Scroll
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        binde = [
          ", XF86AudioRaiseVolume, exec, noctalia msg volume-up"
          ", XF86AudioLowerVolume, exec, noctalia msg volume-down"
          ", XF86AudioMute, exec, noctalia msg volume-mute"
          ", XF86MonBrightnessUp, exec, noctalia msg brightness-up"
          ", XF86MonBrightnessDown, exec, noctalia msg brightness-down"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioStop, exec, playerctl stop"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ];

        windowrulev2 = [
          "noborder, class:^(kitty)$"
          "float, title:^(Picture-in-Picture)$"
        ];
      };
    };
  };
}
