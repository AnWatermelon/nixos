{
  flake.modules.nixos.boot =
    { lib, pkgs, ... }:
    {
      boot = {
        loader.grub = {
          enable = true;
          device = "/dev/sda";
          useOSProber = true;
          fsIdentifier = "provided";
        };
        kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
        consoleLogLevel = 3;
      };
    };
}
