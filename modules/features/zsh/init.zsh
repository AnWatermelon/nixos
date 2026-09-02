# yazi cd-on-exit wrapper
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  if IFS= read -r -d $'\0' cwd < "$tmp"; then
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  fi
  command rm -f -- "$tmp"
}

nr() {
  if (( $# < 1 )); then
    echo "Usage: nr <command> [args...]" >&2
    return 1
  fi

  local cmd="$1"
  shift
  nix run "nixpkgs#${cmd}" -- "$@"
}

fastfetch


eval "$(direnv hook zsh)"

# --- vi-mode indicator (lualine-style colors from noctalia palette) ---
_vi_mode_palette="$HOME/.local/state/zsh/matugen/palette.zsh"
_vi_mode_palette_mtime=-1

# Build one indicator string into REPLY from palette vars. No forks.
_vi_mode_indicator() {
  local _bg="${(P)1}" _fg="${(P)2}"
  if [[ -n "$_bg" && -n "$_fg" ]]; then
    REPLY="%K{${_bg}}%F{${_fg}} $3 %k%f"
  else
    REPLY=" $3 "
  fi
}

_vi_mode_refresh_palette() {
  local _mtime
  if [[ -f "$_vi_mode_palette" ]]; then
    if _mtime=$(zstat +mtime "$_vi_mode_palette" 2>/dev/null) && (( _mtime != _vi_mode_palette_mtime )); then
      _vi_mode_palette_mtime=$_mtime
      source "$_vi_mode_palette" 2>/dev/null
    fi
  else
    _vi_mode_palette_mtime=-1
    unset VI_MODE_IND_NORMAL_BG VI_MODE_IND_INSERT_BG VI_MODE_IND_VISUAL_BG VI_MODE_IND_FG
  fi
  _vi_mode_indicator VI_MODE_IND_NORMAL_BG VI_MODE_IND_FG NORMAL
  MODE_INDICATOR="$REPLY"
  _vi_mode_indicator VI_MODE_IND_INSERT_BG VI_MODE_IND_FG INSERT
  INSERT_MODE_INDICATOR="$REPLY"
  _vi_mode_indicator VI_MODE_IND_VISUAL_BG VI_MODE_IND_FG VISUAL
  VISUAL_MODE_INDICATOR="$REPLY"
}
zmodload -F zsh/stat b:zstat
_vi_mode_refresh_palette
precmd_functions+=(_vi_mode_refresh_palette)

# Plain parameter (no fork), expanded by prompt_subst on each redraw.
VI_MODE_IND="${INSERT_MODE_INDICATOR}"
_vi_mode_set_indicator() {
  case "${VI_KEYMAP:-main}" in
    vicmd|viopp)
      if (( ${REGION_ACTIVE:-0} )); then
        VI_MODE_IND="${VISUAL_MODE_INDICATOR}"
      else
        VI_MODE_IND="${MODE_INDICATOR}"
      fi
      ;;
    *) VI_MODE_IND="${INSERT_MODE_INDICATOR}" ;;
  esac
}

# Visual selection never changes $KEYMAP (stays vicmd) — detect it from
# REGION_ACTIVE (1=char, 2=line) on every pre-redraw.
_vi_mode_pre_redraw() {
  local _old="${VI_MODE_IND}"
  _vi_mode_set_indicator
  [[ "$VI_MODE_IND" != "$_old" ]] && zle reset-prompt
}
autoload -Uz add-zle-hook-widget
add-zle-hook-widget zle-line-pre-redraw _vi_mode_pre_redraw

# Override the plugin's widgets: update indicator + cursor + redraw.
function zle-keymap-select() {
  typeset -g VI_KEYMAP=$KEYMAP
  _vi_mode_set_indicator
  _vi-mode-set-cursor-shape-for-keymap "${VI_KEYMAP}"
  zle reset-prompt
  zle -R
}
zle -N zle-keymap-select

function zle-line-init() {
  local prev_vi_keymap="${VI_KEYMAP:-}"
  typeset -g VI_KEYMAP=main
  _vi_mode_set_indicator
  [[ "$prev_vi_keymap" != 'main' ]] && zle reset-prompt
  (( ! ${+terminfo[smkx]} )) || echoti smkx
  _vi-mode-set-cursor-shape-for-keymap "${VI_KEYMAP}"
}
zle -N zle-line-init

function zle-line-finish() {
  typeset -g VI_KEYMAP=main
  _vi_mode_set_indicator
  (( ! ${+terminfo[rmkx]} )) || echoti rmkx
  _vi-mode-set-cursor-shape-for-keymap default
}
zle -N zle-line-finish

# Splice the indicator into the END of prompt line 1 (gnzh line 1
# already ends with a space, so no extra separator is needed).
# NOTE: the ${VI_MODE_IND} is SINGLE-QUOTED so it stays literal in
# PROMPT at set time and is re-expanded by prompt_subst each render.
PROMPT="${PROMPT%%$'\n'*}"\${VI_MODE_IND}$'\n'"${PROMPT#*$'\n'}"
