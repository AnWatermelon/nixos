{
  flake.modules.nixos.networking = {
    networking.networkmanager.enable = true;
    services.resolved.enable = true;
  };
}
