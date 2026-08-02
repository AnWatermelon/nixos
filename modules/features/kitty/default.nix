{ lib, ... }:
{
  flake.modules.homeManager.kitty = {
    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 12;
      };
      shellIntegration.mode = "no-cursor";
      settings = {
        background_opacity = 0.8;
        background_blur = 1;
        term = "xterm-kitty";
        enable_audio_bell = false;
        linux_display_server = "auto";

        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";

        cursor_shape = "beam";
        cursor_blink_interval = 0.25;
        cursor_stop_blinking_after = 1.5;

        scrollback_lines = 5000;
        wheel_scroll_multiplier = 3.0;

        mouse_hide_wait = -1;

        remember_window_size = false;
        initial_window_width = 1200;
        initial_window_height = 750;
        window_border_width = "1.5pt";
        enabled_layouts = "tall";
        window_padding_width = 0;
        window_margin_width = 2;
        hide_window_decorations = true;

        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_bar_edge = "bottom";
        tab_bar_align = "left";
        active_tab_font_style = "bold";
        inactive_tab_font_style = "normal";
      };
      keybindings = {
        "ctrl+shift+backspace" = "change_font_size all 0";
        "ctrl+shift+." = "change_font_size all +1";
        "ctrl+shift+," = "change_font_size all -1";
        "alt+enter" = "new_window";
        "alt+right" = "next_window";
        "alt+left" = "previous_window";
        "alt+q" = "close_window";
        "alt+r" = "start_resizing_window";
        "ctrl+shift+t" = "new_tab";
        "ctrl+shift+right" = "next_tab";
        "ctrl+shift+left" = "previous_tab";
        "ctrl+shift+w" = "close_tab";
      };
      # globinclude (unlike include) is a no-op when the file is absent, so a
      # fresh machine does not error before noctalia has rendered its theme.
      extraConfig = lib.mkBefore ''
        globinclude themes/noctalia.conf
      '';
    };
  };
}
