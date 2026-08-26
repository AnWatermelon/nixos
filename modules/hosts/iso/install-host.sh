set -euo pipefail


usage() {
  cat <<'EOF'
Usage: install-host [OPTIONS] <host>

Install the NixOS configuration <host> (e.g. fw13p, nixos-test) onto a
target disk using the bundled two-stage process.

Options:
  --disk DEVICE      Target disk (e.g. /dev/vda). WARNING: everything on
                     it will be destroyed. Required.
  --layout NAME      Partition layout: btrfs (default) or ext4.
  --keep-hardware    Keep the target host's committed hardware
                     configuration instead of regenerating it. Use this
                     when installing onto a machine that matches an
                     existing hand-written config.
  --no-reboot        Do not reboot automatically after a successful
                     install.
  -h, --help         Show this help.

The target <host> must be a NixOS host in this flake.

If <host> ships a pre-generated SSH host key
(modules/hosts/<host>/ssh_host_ed25519_key.age), you will be prompted
for its age passphrase before any changes are made. The key decrypts
the host's sops secrets at first boot. If the ISO was built with the
host keys unlocked (`nix run .#build-iso`, or
MAX_ISO_PASSPHRASE_FILE=... nix build --impure .#iso), the key is
already unlocked on the ISO and no prompt appears.
EOF
}

die() {
  echo "install-host: error: $*" >&2
  exit 1
}

HOST=""
DISK=""
LAYOUT="btrfs"
KEEP_HW=0
REBOOT=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --disk)
      DISK="$2"
      shift 2
      ;;
    --layout)
      LAYOUT="$2"
      shift 2
      ;;
    --keep-hardware)
      KEEP_HW=1
      shift
      ;;
    --no-reboot)
      REBOOT=0
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      die "unknown option: $1 (see --help)"
      ;;
    *)
      HOST="$1"
      shift
      ;;
  esac
done

[[ -n "$HOST" ]] || die "missing host argument (see --help)"
[[ -n "$DISK" ]] || die "--disk is required; refusing to guess (see --help)"
[[ "$EUID" -eq 0 ]] || die "must run as root"

FLAKE_SRC="/iso/etc/nixos/flake"
LAYOUT_DIR="${MAX_LAYOUT_DIR:-/nonexistent}"
WORK="/tmp/install-host-flake"

[[ -d "$FLAKE_SRC" ]] || die "flake not found at $FLAKE_SRC (are you on the Max ISO?)"
[[ -f "$LAYOUT_DIR/$LAYOUT.nix" ]] || die "unknown layout '$LAYOUT' (available: btrfs, ext4)"
[[ -b "$DISK" ]] || die "$DISK is not a block device"

read -r -p "DESTROY all data on $DISK and install host '$HOST'? Type '$HOST' to confirm: " confirm
[[ "$confirm" == "$HOST" ]] || die "aborted"

HOSTKEY_AGE="$FLAKE_SRC/modules/hosts/$HOST/ssh_host_ed25519_key.age"
HOSTKEY_TMP="/tmp/install-host-${HOST}-hostkey"
UNLOCKED_KEY="/iso/unlocked-hostkeys/$HOST/ssh_host_ed25519_key"
if [[ -f "$UNLOCKED_KEY" ]]; then
  echo "==> Using SSH host key pre-unlocked at ISO build time (sops secrets are keyed to it)"
  cp "$UNLOCKED_KEY" "$HOSTKEY_TMP"
  chmod 600 "$HOSTKEY_TMP"
elif [[ -f "$HOSTKEY_AGE" ]]; then
  echo "==> Decrypting pre-generated SSH host key for $HOST (sops secrets are keyed to it)"
  rm -f "$HOSTKEY_TMP"
  for attempt in 1 2 3; do
    if age -d -o "$HOSTKEY_TMP" "$HOSTKEY_AGE"; then
      chmod 600 "$HOSTKEY_TMP"
      break
    fi
    if [[ $attempt -eq 3 ]]; then
      die "host key decryption failed after 3 attempts"
    fi
    echo "    (attempt $attempt failed; try again)"
  done
else
  echo "==> No pre-generated SSH host key for $HOST (skipping)"
fi

echo "==> Partitioning $DISK with layout '$LAYOUT'"
disko --mode destroy,format,mount "$LAYOUT_DIR/$LAYOUT.nix" --argstr disk "$DISK" --yes-wipe-all-disks

echo "==> Copying flake to $WORK"
rm -rf "$WORK"
cp -a "$FLAKE_SRC" "$WORK"

HW_MIN="$WORK/modules/hosts/minimal/_hardware-configuration.nix"
HW_TARGET="$WORK/modules/hosts/$HOST/_hardware-configuration.nix"
[[ -f "$HW_MIN" ]] || die "no minimal host hardware config in the flake copy"
[[ -d "$WORK/modules/hosts/$HOST" ]] || die "no host '$HOST' in the flake"
[[ "$KEEP_HW" -ne 1 || -f "$HW_TARGET" ]] || die "--keep-hardware: '$HOST' has no committed hardware config"

echo "==> Generating hardware configuration"
nixos-generate-config --root /mnt --show-hardware-config | sed '/systemd-boot/d' >"$HW_MIN"
if [[ "$KEEP_HW" -ne 1 ]]; then
  cp "$HW_MIN" "$HW_TARGET"
fi

echo "==> Selecting bootloader (detected: $([ -d /sys/firmware/efi ] && echo EFI || echo BIOS))"
if [[ -d /sys/firmware/efi ]]; then
  BOOTLOADER='{ boot.loader.grub = { enable = true; efiSupport = true; efiInstallAsRemovable = true; device = "nodev"; }; }'
else
  printf -v BOOTLOADER '{ boot.loader.grub = { enable = true; device = "%s"; }; }' "$DISK"
fi
printf '%s\n' "$BOOTLOADER" >"$WORK/modules/hosts/minimal/_bootloader.nix"
printf '%s\n' "$BOOTLOADER" >"$WORK/modules/hosts/$HOST/_bootloader.nix"

echo "==> Recording target host"
mkdir -p /mnt/etc
echo "$HOST" >/mnt/etc/install-target
if [[ -n "${FLAKE_REV:-}" ]]; then
  echo "$FLAKE_REV" >/mnt/etc/install-flake-rev
fi
# install-finalize regenerates the generated configs whenever the /etc/nixos
# tree is reset, so record what it needs: the disk device (BIOS grub) and
# whether the target's hardware configuration must survive regeneration.
echo "$DISK" >/mnt/etc/install-disk
if [[ "$KEEP_HW" -eq 1 ]]; then
  touch /mnt/etc/install-keep-hardware
fi

echo "==> Installing minimal bootstrap system (stage 1)"
nixos-install --flake "$WORK#minimal" --no-root-passwd --no-channel-copy

echo "==> Copying flake into the installed system"
rm -rf /mnt/etc/nixos
cp -a "$WORK" /mnt/etc/nixos

echo "==> Restoring git repository in /etc/nixos"
git -C /mnt/etc/nixos init -q -b main
git -C /mnt/etc/nixos remote add origin gitea@gitea.hilton-tech.net:max_hilton/nixos
git -C /mnt/etc/nixos remote add github https://github.com/AnWatermelon/nixos
git -C /mnt/etc/nixos add -A

if [[ -f "$HOSTKEY_TMP" ]]; then
  echo "==> Installing SSH host key into the new system"
  mkdir -p /mnt/etc/ssh
  install -m 600 "$HOSTKEY_TMP" /mnt/etc/ssh/ssh_host_ed25519_key
  ssh-keygen -y -f /mnt/etc/ssh/ssh_host_ed25519_key >/mnt/etc/ssh/ssh_host_ed25519_key.pub
  rm -f "$HOSTKEY_TMP"
fi

cat <<EOF

Install complete. On first boot, the minimal system will automatically
switch to host '$HOST' (this needs a network connection); progress is
shown on the console, and the switch retries until it succeeds.

/etc/nixos is a git repository tracking
gitea@gitea.hilton-tech.net:max_hilton/nixos (hosts without the shared
key sync from the GitHub mirror instead). Its history is synced from
the remote before the final switch, so 'git pull' works for updates
afterwards.

The minimal system uses the bootstrap password 'nixos' (user maxfh,
SSH enabled). Root gets locked once the final system has booted
successfully, and you should set a real password for maxfh right away.

EOF

if [[ "$REBOOT" -eq 1 ]]; then
  echo "==> Unmounting and rebooting into the new system"
  umount -R /mnt
  systemctl reboot
else
  echo "==> Reboot skipped (--no-reboot); unmount and reboot when ready:"
  echo "    umount -R /mnt && systemctl reboot"
fi
