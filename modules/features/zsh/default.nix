{
  flake.modules.homeManager.zsh =
    { pkgs, lib, ... }:
    {
      programs.zsh = {
        enable = true;
        autocd = true;
        enableCompletion = false;
        localVariables = {
          DISABLE_MAGIC_FUNCTIONS = "true";
          KEYTIMEOUT = "1";
        };
        shellAliases = {
          sp = "spotify_player";
          cfg = "cd ~/.config/";
          lg = "lazygit";
          p = "cd ~/Projects";
          s = "cd ~/shared/Documents/School";
          nrb = "sudo nixos-rebuild switch --flake /home/maxfh/Projects/nixos";
          hms = "home-manager switch --flake ~/Projects/nixos#maxfh";
          nfc = "nix flake check && nix formatter run";
          tdu = "sudo ncdu --exclude '/.snapshots' --exclude '/mnt' /";
          nbs = "sudo netbird-wt0 status -d";
          nbd = "sudo netbird-wt0 down";
          nbu = "sudo netbird-wt0 up";
          nbr = "sudo netbird-wt0 down && sudo netbird-wt0 up";
        };
        initContent = lib.mkMerge [
          (lib.mkOrder 200 ''
            if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
              source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
            fi
          '')
          (lib.mkOrder 600 ''
            autoload -Uz compinit
            local zcompdump="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
            mkdir -p "''${zcompdump:h}"
            if [[ -f $zcompdump && $(date +%j) == $(date -r $zcompdump +%j 2>/dev/null) ]]; then
              compinit -C -d "$zcompdump"
            else
              compinit -d "$zcompdump"
            fi
          '')
          (lib.mkOrder 700 ''
            bindkey -v

            _set_cursor() {
              case $KEYMAP in
                vicmd)      print -n '\e[2 q' ;;  # block
                viins|main) print -n '\e[6 q' ;;  # beam
              esac
            }
            zle -N zle-keymap-select _set_cursor
            zle -N zle-line-init _set_cursor

            _fix_cursor() { print -n '\e[6 q' }
            precmd_functions+=(_fix_cursor)

            autoload -Uz select-bracketed select-quoted
            zle -N select-bracketed
            zle -N select-quoted
            for km in viopp visual; do
              bindkey -M $km -- '-' vi-up-line-or-history
              for c in {a,i}{\',\",\`,/,\|,\\,\(,\),\[,\],\{,\}}; do
                bindkey -M $km $c select-quoted
              done
              for c in {a,i}''${(s..)^:-'()[]{}<>bB'}; do
                bindkey -M $km $c select-bracketed
              done
            done

            bindkey '^P' up-history
            bindkey '^N' down-history
            bindkey -M command '^[' send-break
          '')
          (lib.mkOrder 800 ''
            source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
            [[ ! -f ~/.config/zsh/p10k.zsh ]] || source ~/.config/zsh/p10k.zsh
          '')
          (builtins.readFile ./init.zsh)
        ];
      };

      xdg.configFile."zsh/p10k.zsh".source = ./p10k.zsh;
    };
}
