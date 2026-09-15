_: {
  flake.modules.homeManager.ghostty =
    {
      config,
      lib,
      ...
    }:
    {
      programs.ghostty = lib.mkIf (lib.getName config.my.terminal == "ghostty") {
        enable = true;
        settings = {
          font-family = "JetBrainsMono Nerd Font";
          font-size = 12;

          background-opacity = 1.0;
          background-blur = 20;
          window-decoration = false;

          cursor-style = "bar";
          mouse-hide-while-typing = true;

          scrollback-limit = 5000000;
          confirm-close-surface = false;

          keybind = [
            "ctrl+shift+backspace=reset_font_size"
            "ctrl+shift+period=increase_font_size:1"
            "ctrl+shift+comma=decrease_font_size:1"
            "alt+enter=new_split:auto"
            "alt+q=close_surface"
          ];

          config-file = "?themes/noctalia.conf";
        };
      };
    };
}
