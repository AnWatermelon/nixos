{ config, lib, pkgs, ... }:
{
  config.flake.modules.nixos.boot = { pkgs, lib, ... }: {
    boot.loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
      fsIdentifier = "provided";
    };
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };
}
