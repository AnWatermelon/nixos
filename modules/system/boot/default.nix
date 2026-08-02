{
  flake.modules.nixos.boot =
    { lib, pkgs, ... }:
    {
      boot.loader.grub = {
        enable = true;
        device = "/dev/sda";
        useOSProber = true;
        fsIdentifier = "provided";
      };

      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      boot.consoleLogLevel = 3;
    };
}
