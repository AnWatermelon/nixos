{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "sr_mod"
        "rtsx_usb_sdmmc"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/ef2bd4db-de41-4072-b1a5-c5a412bac30e";
      fsType = "btrfs";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/ef2bd4db-de41-4072-b1a5-c5a412bac30e";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/ef2bd4db-de41-4072-b1a5-c5a412bac30e";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/e579dd9b-74ac-4180-8ef4-879762d8f8bd"; } ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
