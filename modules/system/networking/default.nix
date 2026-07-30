{ config, ... }:
{
  config.flake.modules.nixos.networking = { ... }: {
    networking.networkmanager.enable = true;
  };
}
