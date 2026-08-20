{
  flake.modules.homeManager.zsh = {
    programs.zsh = {
      enable = true;
      localVariables.VI_MODE_SET_CURSOR = "true";
      localVariables.KEYTIMEOUT = "10";
      shellAliases = {
        sp = "spotatui";
        cfg = "cd ~/.config/";
        lg = "lazygit";
        p = "cd ~/Projects";
        nrb = "sudo nixos-rebuild switch";
        hms = "home-manager switch --flake ~/Projects/nixos#maxfh";
        nfc = "nix formatter run && nix flake check";
      };
      oh-my-zsh = {
        enable = true;
        theme = "gnzh";
        plugins = [
          "vi-mode"
        ];
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

        fastfetch

        # LM Studio CLI
        export PATH="$PATH:$HOME/.lmstudio/bin:$HOME/.local/bin"

        eval "$(direnv hook zsh)"

        # --- vi-mode indicator (lualine-style colors from noctalia palette) ---
        _vi_mode_palette="$HOME/.local/state/zsh/matugen/palette.zsh"
        _vi_mode_palette_mtime=-1
        _vi_mode_refresh_palette() {
          local _mtime
          if [[ -f "$_vi_mode_palette" ]] && _mtime=$(zstat +mtime "$_vi_mode_palette" 2>/dev/null) && (( _mtime != _vi_mode_palette_mtime )); then
            _vi_mode_palette_mtime=$_mtime
            source "$_vi_mode_palette"
          fi
          MODE_INDICATOR="%K{''${VI_MODE_IND_NORMAL_BG:-#f0b0ff}}%F{''${VI_MODE_IND_FG:-#1f1f1f}} NORMAL %k%f"
          INSERT_MODE_INDICATOR="%K{''${VI_MODE_IND_INSERT_BG:-#f0b0ff}}%F{''${VI_MODE_IND_FG:-#1f1f1f}} INSERT %k%f"
          VISUAL_MODE_INDICATOR="%K{''${VI_MODE_IND_VISUAL_BG:-#d5c0d6}}%F{''${VI_MODE_IND_FG:-#1f1f1f}} VISUAL %k%f"
        }
        zmodload -F zsh/stat b:zstat
        _vi_mode_refresh_palette
        precmd_functions+=(_vi_mode_refresh_palette)

        # Plain parameter (no fork), expanded by prompt_subst on each redraw.
        VI_MODE_IND="''${INSERT_MODE_INDICATOR}"
        _vi_mode_set_indicator() {
          case "''${VI_KEYMAP:-main}" in
            vicmd|viopp) VI_MODE_IND="''${MODE_INDICATOR}" ;;
            visual) VI_MODE_IND="''${VISUAL_MODE_INDICATOR}" ;;
            *) VI_MODE_IND="''${INSERT_MODE_INDICATOR}" ;;
          esac
        }

        # Override the plugin's widgets: update indicator + cursor + redraw.
        function zle-keymap-select() {
          typeset -g VI_KEYMAP=$KEYMAP
          _vi_mode_set_indicator
          _vi-mode-set-cursor-shape-for-keymap "''${VI_KEYMAP}"
          zle reset-prompt
          zle -R
        }
        zle -N zle-keymap-select

        function zle-line-init() {
          local prev_vi_keymap="''${VI_KEYMAP:-}"
          typeset -g VI_KEYMAP=main
          _vi_mode_set_indicator
          [[ "$prev_vi_keymap" != 'main' ]] && zle reset-prompt
          (( ! ''${+terminfo[smkx]} )) || echoti smkx
          _vi-mode-set-cursor-shape-for-keymap "''${VI_KEYMAP}"
        }
        zle -N zle-line-init

        function zle-line-finish() {
          typeset -g VI_KEYMAP=main
          _vi_mode_set_indicator
          (( ! ''${+terminfo[rmkx]} )) || echoti rmkx
          _vi-mode-set-cursor-shape-for-keymap default
        }
        zle -N zle-line-finish

        # Splice the indicator into the END of prompt line 1 (gnzh line 1
        # already ends with a space, so no extra separator is needed).
        # NOTE: the ''${VI_MODE_IND} is SINGLE-QUOTED so it stays literal in
        # PROMPT at set time and is re-expanded by prompt_subst each render.
        PROMPT="''${PROMPT%%$'\n'*}"\''${VI_MODE_IND}$'\n'"''${PROMPT#*$'\n'}"
      '';
    };
    home.file.".local/state/zsh/matugen/.keep".text = "";
  };
}
