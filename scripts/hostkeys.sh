#!/usr/bin/env bash
set -euo pipefail

# Manages the YubiKey-sealed copies of the hosts' SSH host keys (which
# double as their sops-nix age keys), so install-host can unlock them
# with a touch instead of the age passphrase.
#
#   hostkeys enroll        register a YubiKey (once per key)
#   hostkeys seal [HOST]   encrypt host keys to every registered YubiKey
#
# Keys are sealed with age-plugin-fido2-hmac without a separate identity:
# the stanza carries the FIDO2 credential, so `age -d -j fido2-hmac`
# decrypts with any registered key and no other file. Sealing needs no
# YubiKey. The passphrase-encrypted ssh_host_ed25519_key.age stays as the
# fallback.

if [[ "$0" == /nix/store/* ]]; then
  FLAKE="$PWD"
else
  cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
  FLAKE="$PWD"
fi
HOSTS="$FLAKE/modules/hosts"
RECIPIENTS="$HOSTS/yubikeys.txt"

say() { echo "hostkeys: $*" >&2; }
die() {
  say "error: $*"
  exit 1
}

usage() {
  cat <<'EOF'
Usage: hostkeys enroll
       hostkeys seal [HOST...]

enroll  Creates a FIDO2 credential on the inserted YubiKey and adds its
        age recipient to modules/hosts/yubikeys.txt. Answer "yes" to
        requiring a PIN and "no" to a separate identity.
seal    Decrypts each host's ssh_host_ed25519_key.age with the age
        passphrase and writes ssh_host_ed25519_key.yubikey.age, readable
        with any enrolled YubiKey. Defaults to every host with a key.
        Rerun it after enrolling another YubiKey.
EOF
}

for tool in age age-plugin-fido2-hmac script; do
  command -v "$tool" >/dev/null || die "missing $tool; run this through 'nix run .#hostkeys'"
done

enroll() {
  [[ -t 0 ]] || die "enroll needs a terminal"
  local out recipient label
  say "answer \"yes\" to requiring a PIN and \"no\" to a separate identity"
  out="$(age-plugin-fido2-hmac -g)"
  recipient="$(sed -n 's/^# public key: \(age1fido2-hmac1[a-z0-9]*\)$/\1/p' <<<"$out")"
  [[ -n "$recipient" ]] || die "no plugin recipient generated; was a separate identity chosen? Rerun and answer \"no\""
  read -rp "hostkeys: label for this key (e.g. yubikey 1): " label
  printf '# %s, enrolled %s\n%s\n' "${label:-yubikey}" "$(date +%F)" "$recipient" >>"$RECIPIENTS"
  say "added to ${RECIPIENTS#"$FLAKE"/}; run 'hostkeys seal' to reseal the host keys"
}

# Decrypts $1 to $2 with $phrase. age only reads passphrases from a
# terminal, so feed it through a pty; the pty's output is discarded in
# case it echoes the passphrase back.
decrypt() {
  printf '%s\n' "$phrase" |
    script -qec "age -d -o $(printf '%q' "$2") $(printf '%q' "$1")" /dev/null >/dev/null 2>&1
}

seal() {
  grep -qs '^age1' "$RECIPIENTS" || die "no YubiKeys enrolled; run 'hostkeys enroll' first"
  [[ -t 0 ]] || die "seal needs a terminal for the age passphrase"

  local hosts=("$@") host
  if [[ ${#hosts[@]} -eq 0 ]]; then
    for f in "$HOSTS"/*/ssh_host_ed25519_key.age; do
      [[ -f "$f" ]] && hosts+=("$(basename "$(dirname "$f")")")
    done
  fi
  [[ ${#hosts[@]} -gt 0 ]] || die "no host keys found"
  for host in "${hosts[@]}"; do
    [[ -f "$HOSTS/$host/ssh_host_ed25519_key.age" ]] || die "$host has no ssh_host_ed25519_key.age"
  done

  umask 077
  # Global: the EXIT trap runs after seal returns.
  if [[ -d "/run/user/$(id -u)" ]]; then
    tmp="$(mktemp -d "/run/user/$(id -u)/hostkeys.XXXXXX")"
  else
    say "warning: no /run/user tmpfs; decrypted keys will go through $TMPDIR"
    tmp="$(mktemp -d)"
  fi
  trap 'rm -rf "$tmp"' EXIT

  local attempt failed
  for attempt in 1 2 3; do
    read -rsp "hostkeys: age passphrase for the host keys: " phrase
    echo >&2
    failed=""
    for host in "${hosts[@]}"; do
      if ! decrypt "$HOSTS/$host/ssh_host_ed25519_key.age" "$tmp/$host"; then
        failed="$host"
        break
      fi
    done
    [[ -z "$failed" ]] && break
    say "could not decrypt $failed's host key (wrong passphrase?)"
    [[ $attempt -lt 3 ]] || die "giving up"
  done
  unset phrase

  for host in "${hosts[@]}"; do
    age -R "$RECIPIENTS" -o "$HOSTS/$host/ssh_host_ed25519_key.yubikey.age" "$tmp/$host"
    say "sealed $host"
  done
}

case "${1:-}" in
  enroll)
    shift
    [[ $# -eq 0 ]] || die "enroll takes no arguments"
    enroll
    ;;
  seal)
    shift
    seal "$@"
    ;;
  -h | --help)
    usage
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
