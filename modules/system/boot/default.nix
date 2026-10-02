{
  flake.modules.nixos.boot =
    { lib, pkgs, ... }:
    {
      boot = {
        loader.grub = {
          enable = true;
          useOSProber = true;
          fsIdentifier = "provided";
          configurationLimit = 5;
        };
        kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
        consoleLogLevel = 3;
      };
    };
}
