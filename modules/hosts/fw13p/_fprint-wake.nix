# Framework 13 wake workaround for the Goodix fingerprint reader (27c6:609c).
# Port of FrameworkComputer/linux-docs Fingerprint-Wake-Workaround: after
# resume the sensor can vanish from USB. If it is gone, rebind the xHCI
# controller it hangs off and try-restart fprintd.
#
# The controller's PCI address is resolved at boot (when the reader is
# present) into /run/fprint-wake, because at wake time the device may already
# be gone.
{
  pkgs,
  ...
}:
{
  systemd.services.fprint-wake-resolve = {
    description = "Resolve fingerprint reader xHCI controller (Framework wake workaround)";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-settle.service" ];
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ coreutils gnugrep util-linux usbutils ];
    script = ''
      for dev in /sys/bus/usb/devices/*; do
        [ -r "$dev/idVendor" ] || continue
        vid="$(cat "$dev/idVendor" 2>/dev/null)"
        pid="$(cat "$dev/idProduct" 2>/dev/null)"
        if [ "$vid" = "27c6" ] && [ "$pid" = "609c" ]; then
          pci="$(readlink -f "$dev" | grep -oE '[0-9a-f]{4}:[0-9a-f]{2}:[0-9a-f]{2}\.[0-9]' | tail -1)"
          driver="$(basename "$(readlink -f "/sys/bus/pci/devices/$pci/driver" 2>/dev/null)" 2>/dev/null)"
          case "$driver" in
            xhci*) ;;
            *)
              logger -t fp-rebind "controller $pci uses driver '$driver', not xHCI; not caching"
              exit 1
              ;;
          esac
          mkdir -p /run/fprint-wake
          printf '%s\n' "$pci" > /run/fprint-wake/pci
          printf '%s\n' "$driver" > /run/fprint-wake/driver
          logger -t fp-rebind "fingerprint reader on PCI $pci (driver $driver)"
          exit 0
        fi
      done
      logger -t fp-rebind "fingerprint reader not found; wake workaround will be inert"
      rm -f /run/fprint-wake/pci /run/fprint-wake/driver
    '';
  };

  systemd.services.fprint-wake = {
    description = "Restore fingerprint reader after system resume";
    after = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    wantedBy = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ coreutils usbutils util-linux systemd ];
    script = ''
      pci="$(cat /run/fprint-wake/pci 2>/dev/null)"
      driver="$(cat /run/fprint-wake/driver 2>/dev/null)"

      logger -t fp-rebind "Checking fingerprint reader after wake"
      sleep 2

      if lsusb -d 27c6:609c >/dev/null 2>&1; then
        logger -t fp-rebind "Reader present, no action needed"
        exit 0
      fi

      if [ -z "$pci" ] || [ -z "$driver" ]; then
        logger -t fp-rebind "ERROR: no cached controller, cannot rebind"
        exit 1
      fi

      logger -t fp-rebind "Fingerprint missing, resetting controller $pci"

      if ! echo "$pci" > "/sys/bus/pci/drivers/$driver/unbind" 2>/dev/null; then
        logger -t fp-rebind "ERROR: Unbind failed"
        exit 1
      fi

      sleep 1

      if ! echo "$pci" > "/sys/bus/pci/drivers/$driver/bind" 2>/dev/null; then
        logger -t fp-rebind "ERROR: Rebind failed"
        exit 1
      fi

      sleep 2
      systemctl try-restart fprintd.service

      if lsusb -d 27c6:609c >/dev/null 2>&1; then
        logger -t fp-rebind "SUCCESS: Reader restored"
      else
        logger -t fp-rebind "WARNING: Reader still missing"
      fi
    '';
  };
}
