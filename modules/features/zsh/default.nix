{ inputs, ... }:
{
  flake.modules.nixos.zsh =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      zshWrapper = config.wrappers.zsh.wrapper;
    in
    {
      imports = [
        (inputs.nix-wrapper-modules.lib.getInstallModule {
          name = "zsh";
          value = inputs.nix-wrapper-modules.wrapperModules.zsh;
        })
      ];

      wrappers.zsh = {
        enable = true;
        # hm-session-vars no longer exists; /etc/zshenv carries the environment
        hmSessionVariables = null;

        zshAliases = {
          ls = "ls --hyperlink=auto";
          sp = "spotify_player";
          cfg = "cd ~/.config/";
          lg = "lazygit";
          p = "cd ~/Projects";
          s = "cd ~/shared/Documents/School";
          nfc = "nix fmt && nix flake check";
          tdu = "sudo ncdu --exclude '/.snapshots' --exclude '/mnt' --exclude '/home/maxfh/shared' /";
          nbs = "sudo netbird-wt0 status -d";
          nbd = "sudo touch /run/netbird-wt0-watchdog.paused && sudo netbird-wt0 down";
          nbu = "sudo rm -f /run/netbird-wt0-watchdog.paused; sudo netbird-wt0 up";
          nbr = "sudo netbird-wt0 down && sudo netbird-wt0 up";
        };

        zshrc.content = lib.concatStringsSep "\n" [
          ''
            if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
              source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
            fi

            typeset -U path cdpath fpath manpath

            DISABLE_MAGIC_FUNCTIONS="true"
            KEYTIMEOUT="1"
          ''
          ''
            autoload -Uz compinit
            local zcompdump="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
            mkdir -p "''${zcompdump:h}"
            if [[ -f $zcompdump && $(date +%j) == $(date -r $zcompdump +%j 2>/dev/null) ]]; then
              compinit -C -d "$zcompdump"
            else
              compinit -d "$zcompdump"
            fi
          ''
          ''
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
          ''
          ''
            source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
            [[ ! -f ~/.config/zsh/p10k.zsh ]] || source ~/.config/zsh/p10k.zsh
          ''
          # set after /etc/zshrc, which sets its own history defaults
          ''
            HISTSIZE="10000"
            SAVEHIST="10000"

            HISTFILE="$HOME/.zsh_history"
            mkdir -p "$(dirname "$HISTFILE")"

            set_opts=(
              HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY autocd
              NO_APPEND_HISTORY NO_EXTENDED_HISTORY NO_HIST_EXPIRE_DUPS_FIRST
              NO_HIST_FIND_NO_DUPS NO_HIST_IGNORE_ALL_DUPS NO_HIST_SAVE_NO_DUPS
            )
            for opt in "''${set_opts[@]}"; do
              setopt "$opt"
            done
            unset opt set_opts
          ''
          (builtins.readFile ./init.zsh)
          # kitty.conf keeps shell_integration no-rc, so source it by hand
          ''
            if test -n "$KITTY_INSTALLATION_DIR"; then
              export KITTY_SHELL_INTEGRATION="no-rc no-cursor"
              autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
              kitty-integration
              unfunction kitty-integration
            fi
          ''
          # /etc/zshenv overrides the ZDOTDIR ghostty injects its integration with
          ''
            if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
              source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
            fi
          ''
          ''
            # each generation is labeled with the commit it was built from,
            # so a dirty tree would produce an inexact label
            nhs() {
              if [[ $1 == --dirty ]]; then
                shift
              else
                local changes
                changes=$(git -C "$NH_FLAKE" status --porcelain) || return 1
                if [[ -n $changes ]]; then
                  echo "nhs: $NH_FLAKE has uncommitted changes; commit them first or run 'nhs --dirty'" >&2
                  return 1
                fi
              fi
              nh os switch --accept-flake-config "$@"
            }
          ''
        ];
      };

      # the wrapper's bin/zsh would collide with programs.zsh in the system
      # profile, so make every zsh (plain `zsh`, nix-shell, scripts) pick up
      # the config by exporting the wrapper's ZDOTDIR from /etc/zshenv
      programs.zsh = {
        enableGlobalCompInit = false;
        shellInit = ''
          export ZDOTDIR=${zshWrapper.ZDOTDIR}
        '';
      };

      users.users.maxfh.shell = zshWrapper;

      my.dotfiles.files.".config/zsh/p10k.zsh".source = ./p10k.zsh;
    };
}
