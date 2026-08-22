set -euo pipefail


usage() {
  cat <<'EOF'
Usage: max-install [OPTIONS] <host>

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
  -h, --help         Show this help.

The target <host> must be a NixOS host in this flake.
EOF
}

die() {
  echo "max-install: error: $*" >&2
  exit 1
}

HOST=""
DISK=""
LAYOUT="btrfs"
KEEP_HW=0

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
WORK="/tmp/max-install-flake"

[[ -d "$FLAKE_SRC" ]] || die "flake not found at $FLAKE_SRC (are you on the Max ISO?)"
[[ -f "$LAYOUT_DIR/$LAYOUT.nix" ]] || die "unknown layout '$LAYOUT' (available: btrfs, ext4)"
[[ -b "$DISK" ]] || die "$DISK is not a block device"

read -r -p "DESTROY all data on $DISK and install host '$HOST'? Type '$HOST' to confirm: " confirm
[[ "$confirm" == "$HOST" ]] || die "aborted"

echo "==> Partitioning $DISK with layout '$LAYOUT'"
disko --mode destroy,format,mount "$LAYOUT_DIR/$LAYOUT.nix" --argstr disk "$DISK" --yes-wipe-all-disks

echo "==> Copying flake to $WORK"
rm -rf "$WORK"
cp -a "$FLAKE_SRC" "$WORK"

HW_MIN="$WORK/modules/hosts/minimal/_hardware-configuration.nix"
HW_TARGET="$WORK/modules/hosts/$HOST/_hardware-configuration.nix"
[[ -f "$HW_MIN" ]] || die "no minimal host hardware config in the flake copy"
[[ -d "$WORK/modules/hosts/$HOST" ]] || die "no host '$HOST' in the flake"
if [[ "$KEEP_HW" -ne 1 && -f "$HW_TARGET" ]]; then
  read -r -p "'$HOST' has a committed hardware config. Overwrite it in the install copy? [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]] || die "aborted"
fi

echo "==> Generating hardware configuration"
nixos-generate-config --root /mnt --show-hardware-config >"$HW_MIN"
if [[ "$KEEP_HW" -ne 1 ]]; then
  cp "$HW_MIN" "$HW_TARGET"
fi

echo "==> Selecting bootloader (detected: $([ -d /sys/firmware/efi ] && echo EFI || echo BIOS))"
if [[ -d /sys/firmware/efi ]]; then
  printf '{ boot.loader.grub = { enable = true; efiSupport = true; efiInstallAsRemovable = true; device = "nodev"; }; }\n' \
    >"$WORK/modules/hosts/minimal/_bootloader.nix"
else
  printf '{ boot.loader.grub = { enable = true; device = "%s"; }; }\n' "$DISK" \
    >"$WORK/modules/hosts/minimal/_bootloader.nix"
fi

echo "==> Recording target host"
mkdir -p /mnt/etc
echo "$HOST" >/mnt/etc/install-target

echo "==> Installing minimal bootstrap system (stage 1)"
nixos-install --flake "$WORK#minimal" --no-root-passwd --no-channel-copy

echo "==> Copying flake into the installed system"
rm -rf /mnt/etc/nixos
cp -a "$WORK" /mnt/etc/nixos

cat <<'EOF'

Install complete. On first boot, the minimal system will automatically
switch to the target host (this needs a network connection). To continue:

  umount -R /mnt && systemctl reboot

The minimal system uses the bootstrap password 'nixos' (user maxfh,
SSH enabled). After the final switch, root gets locked and you should
set a real password for maxfh right away.

EOF
