{ config, lib, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "maxfh";
  home.homeDirectory = "/home/maxfh";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/maxfh/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };
  
  programs.git = {
    enable = true;
    signing.signByDefault = true;
    signing.key = "/home/maxfh/.ssh/id_ed25519.pub";
    settings = {
      gpg.format = "ssh";
      user = {
        name = "Max Hilton";
        email = "maxfhilton52@gmail.com";
      };
    };
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    shellIntegration.mode = "no-cursor";
    settings = {
      # Terminal
      background_opacity = 0.8;
      background_blur = 1;
      term = "xterm-kitty";
      enable_audio_bell = false;
      linux_display_server = "auto";

      # Font overrides
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";

      # Cursor
      cursor_shape = "beam";
      cursor_blink_interval = 0.25;
      cursor_stop_blinking_after = 1.5;

      # Scrollback
      scrollback_lines = 5000;
      wheel_scroll_multiplier = 3.0;

      # Mouse
      mouse_hide_wait = -1;

      # Window
      remember_window_size = false;
      initial_window_width = 1200;
      initial_window_height = 750;
      window_border_width = "1.5pt";
      enabled_layouts = "tall";
      window_padding_width = 0;
      window_margin_width = 2;
      hide_window_decorations = true;

      # Tab bar
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_bar_edge = "bottom";
      tab_bar_align = "left";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";
    };
    keybindings = {
      # Font size
      "ctrl+shift+backspace" = "change_font_size all 0";
      "ctrl+shift+." = "change_font_size all +1";
      "ctrl+shift+," = "change_font_size all -1";
      # Window management
      "alt+enter" = "new_window";
      "alt+right" = "next_window";
      "alt+left" = "previous_window";
      "alt+q" = "close_window";
      # Layout management
      "alt+r" = "start_resizing_window";
      # Tab management
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+w" = "close_tab";
    };
    extraConfig = lib.mkBefore ''
      include themes/noctalia.conf
    '';
  };

  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    settings."*".addKeysToAgent = "yes";
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
