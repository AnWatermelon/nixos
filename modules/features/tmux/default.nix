{
  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        shell = "${pkgs.zsh}/bin/zsh";
        terminal = "screen-256color";
        baseIndex = 1;

        plugins = with pkgs.tmuxPlugins; [
          sensible
          resurrect
          continuum
          yank
          vim-tmux-navigator
          cpu
          battery
          prefix-highlight
        ];

        extraConfig = ''
          # Optional customizations
          set -g @continuum-restore 'on'

          # True color support in modern terminal emulators
          set -as terminal-features ",xterm-256color:RGB"
          set -as terminal-features ",xterm-kitty:RGB"
          set -as terminal-features ",ghostty:RGB"

          # Status bar layout and styling
          set -g status on
          set -g status-position bottom
          set -g status-interval 2
          set -g status-justify left
          set -g status-style "bg=default,fg=default"
          set -g renumber-windows on

          # Left side: tabs flush to the left
          set -g status-left ""
          set -g status-left-length 50

          # Tab formatting with powerline arrow separators
          set -g window-status-separator ""
          set -g window-status-style "bg=default,fg=default"
          set -g window-status-current-style "bg=default,fg=default"

          # Active tab: colored with terminal accent (ANSI green / color2) and dark text
          set -g window-status-current-format "#[fg=black,bg=green,bold] #I #W #{?window_zoomed_flag,󰊓 ,}#{?window_end_flag,#[fg=green#,bg=default],#[fg=green#,bg=colour237]}"

          # Inactive tabs: gray, with powerline separators connecting them
          set -g window-status-format "#[fg=colour250,bg=colour237] #I #W #{?window_zoomed_flag,󰊓 ,}#{?window_end_flag,#[fg=colour237#,bg=default],#{?#{==:#{e|+:#{window_index},1},#{active_window_index}},#[fg=colour237#,bg=green],#[fg=colour244#,bg=colour237] }}"

          # Right side: system info (CPU, optional Battery, Session name, Clock)
          set -g status-right-length 150
          set -g status-right "#{prefix_highlight}#[fg=colour237,bg=default]#[fg=colour250,bg=colour237]  #{cpu_percentage} #{?#{@battery_exists},#[fg=colour240#,bg=colour237]#[fg=colour252#,bg=colour240] #{battery_icon} #{battery_percentage} #[fg=colour237#,bg=colour240]#[fg=colour250#,bg=colour237],}#[fg=colour244,bg=colour237]#[fg=colour250,bg=colour237]  #S #[fg=colour240,bg=colour237]#[fg=colour253,bg=colour240] %H:%M "

          # prefix-highlight plugin styling
          set -g @prefix_highlight_fg "black"
          set -g @prefix_highlight_bg "yellow"
          set -g @prefix_highlight_show_copy_mode "on"
          set -g @prefix_highlight_copy_mode_attr "fg=black,bg=yellow,bold"
          set -g @prefix_highlight_show_sync_mode "on"
          set -g @prefix_highlight_sync_mode_attr "fg=black,bg=red,bold"
          set -g @prefix_highlight_prefix_prompt "PREFIX"
          set -g @prefix_highlight_output_prefix "#[fg=yellow,bg=default]#[fg=black,bg=yellow,bold] "
          set -g @prefix_highlight_output_suffix " "
        '';
      };
    };
}
