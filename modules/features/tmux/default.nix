{
  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        shell = "${pkgs.zsh}/bin/zsh";
        terminal = "screen-256color";

        plugins = with pkgs.tmuxPlugins; [
          sensible
          resurrect
          continuum
          yank
          vim-tmux-navigator
          cpu
        ];

        extraConfig = ''
          # Optional customizations
          set -g @continuum-restore 'on'
        '';
      };
    };
}
