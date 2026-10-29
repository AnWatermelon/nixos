#!/usr/bin/env bash
set -euo pipefail

# Builds the ISO, then optionally writes a copy with the hosts' SSH host
# keys (which double as their sops-nix age keys) pre-unlocked, so
# install-host can skip its age passphrase prompt. The passphrase and the
# decrypted keys never enter the Nix store: the keys are decrypted into a
# private tmpfs directory and added to a copy of the built ISO.

if [[ "$0" == /nix/store/* ]]; then
  FLAKE="$PWD"
else
  cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
  FLAKE="$PWD"
fi

say() { echo "build-iso: $*" >&2; }

for tool in age script xorriso; do
  command -v "$tool" >/dev/null || {
    say "missing $tool; run this through 'nix run .#build-iso'"
    exit 1
  }
done

out="$(nix build "$FLAKE#iso" --print-out-paths "$@")"
iso="$(echo "$out"/iso/*.iso)"
[[ -f "$iso" ]] || {
  say "no ISO found in $out"
  exit 1
}
say "built $iso"

keys=()
for age_file in "$FLAKE"/modules/hosts/*/ssh_host_ed25519_key.age; do
  [[ -f "$age_file" ]] && keys+=("$age_file")
done
if [[ ${#keys[@]} -eq 0 ]]; then
  say "no host keys to unlock"
  exit 0
fi
if [[ ! -t 0 ]]; then
  say "stdin is not a terminal; skipping host key unlock"
  exit 0
fi

umask 077
if [[ -d "/run/user/$(id -u)" ]]; then
  tmp="$(mktemp -d "/run/user/$(id -u)/build-iso.XXXXXX")"
else
  say "warning: no /run/user tmpfs; decrypted keys will go through $TMPDIR"
  tmp="$(mktemp -d)"
fi
trap 'rm -rf "$tmp"' EXIT

# Decrypts $1 to $2 with $phrase. age only reads passphrases from a
# terminal, so feed it through a pty; the pty's output is discarded in
# case it echoes the passphrase back.
decrypt() {
  printf '%s\n' "$phrase" |
    script -qec "age -d -o $(printf '%q' "$2") $(printf '%q' "$1")" /dev/null >/dev/null 2>&1
}

for attempt in 1 2 3; do
  read -rsp "build-iso: age passphrase to pre-unlock host keys (empty to skip): " phrase
  echo >&2
  if [[ -z "$phrase" ]]; then
    say "skipped; install-host will prompt for the passphrase"
    exit 0
  fi
  rm -rf "$tmp/unlocked-hostkeys"
  failed=""
  for age_file in "${keys[@]}"; do
    host="$(basename "$(dirname "$age_file")")"
    mkdir -p "$tmp/unlocked-hostkeys/$host"
    if ! decrypt "$age_file" "$tmp/unlocked-hostkeys/$host/ssh_host_ed25519_key"; then
      failed="$host"
      break
    fi
  done
  [[ -z "$failed" ]] && break
  say "could not unlock $failed's host key (wrong passphrase?)"
  if [[ $attempt -eq 3 ]]; then
    say "giving up; the plain ISO is still at $iso"
    exit 1
  fi
done
unset phrase

dest="$FLAKE/$(basename "$iso" .iso)-unlocked.iso"
rm -f "$dest"
xorriso -report_about SORRY \
  -indev "$iso" -outdev "$dest" \
  -map "$tmp/unlocked-hostkeys" /unlocked-hostkeys \
  -boot_image any replay
say "wrote $dest (contains plaintext host keys; delete it once you're done installing)"
