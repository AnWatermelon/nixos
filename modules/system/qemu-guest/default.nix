{
  flake.modules.nixos.qemu-guest = _: {
    services.qemuGuest.enable = true;
  };
}
