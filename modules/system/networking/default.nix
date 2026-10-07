{
  flake.modules.nixos.networking = {
    networking.networkmanager.enable = true;
    services = {
      resolved.enable = true;
      mullvad-vpn = {
        enable = true;
        gui.enable = true;
      };
    };
    hardware.bluetooth.enable = true;
  };
}
