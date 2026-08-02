{
  flake.modules.homeManager.zsh = {
    programs.zsh = {
      enable = true;
      shellAliases = {
        sp = "spotatui";
        cfg = "cd ~/.config/";
        lg = "lazygit";
        p = "cd ~/Projects";
        nrb = "sudo nixos-rebuild switch";
      };
      oh-my-zsh = {
        enable = true;
        theme = "gnzh";
      };
      initContent = ''
        # yazi cd-on-exit wrapper
        function y() {
          local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
          command yazi "$@" --cwd-file="$tmp"
          if IFS= read -r -d $'\0' cwd < "$tmp"; then
            [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
          fi
          command rm -f -- "$tmp"
        }

        # re-run last command with sudo
        fuck() { sudo $(fc -ln -3 | xargs); }

        fastfetch

        # LM Studio CLI
        export PATH="$PATH:$HOME/.lmstudio/bin"
      '';
    };
  };
}
