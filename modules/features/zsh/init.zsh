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

new-project() {
  mkdir -p "$2" && cd "$2" || return
  git init -q
  nix flake init -t github:the-nix-way/dev-templates#$1
  direnv allow
}

