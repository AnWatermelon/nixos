#!/usr/bin/env bash
set -euo pipefail

PHRASE_SRC="${MAX_ISO_PASSPHRASE_SRC:-/root/.config/nixos/iso-passphrase}"

if [[ "$0" == /nix/store/* ]]; then
  FLAKE="$PWD"
else
  cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
  FLAKE="$PWD"
fi

tmp=""
phrase_file=""

cleanup() { [[ -n "$tmp" && -e "$tmp" ]] && rm -f "$tmp"; }
trap cleanup EXIT

if [[ -r "$PHRASE_SRC" ]]; then
  phrase_file="$PHRASE_SRC"
  echo "build-iso: passphrase file readable; host keys will be unlocked" >&2
elif [[ -f "$PHRASE_SRC" ]]; then
  if [[ -d "/run/user/$(id -u)" ]]; then
    tmp="$(mktemp "/run/user/$(id -u)/iso-passphrase.XXXXXX")"
  else
    tmp="$(mktemp "/tmp/iso-passphrase.XXXXXX")"
  fi
  if sudo -p "sudo: enter your password to unlock the ISO host keys: " \
      install -o "$(id -u)" -m 600 "$PHRASE_SRC" "$tmp"; then
    phrase_file="$tmp"
    echo "build-iso: host keys will be unlocked" >&2
  else
    rm -f "$tmp"
    tmp=""
    echo "build-iso: sudo failed; building without unlocked host keys (install-host will prompt)" >&2
  fi
else
  echo "build-iso: no passphrase file at $PHRASE_SRC; building without unlocked host keys" >&2
  echo "build-iso: create one with:  sudo install -D -m 600 /dev/stdin $PHRASE_SRC <<< 'your phrase'" >&2
fi

if [[ -n "$phrase_file" ]]; then
  export MAX_ISO_PASSPHRASE_FILE="$phrase_file"
fi

exec nix build --impure "$FLAKE#iso" "$@"
