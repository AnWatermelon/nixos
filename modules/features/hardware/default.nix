{ lib, ... }:
{
  flake.modules.nixos.hardware =
    { config, ... }:
    let
      cfg = config.my.hardware;
    in
    {
      imports = [ ./options.nix ];
      config = lib.mkMerge [
        (lib.mkIf (cfg.gpu.devices != [ ]) {
          services.udev.extraRules = lib.concatMapStringsSep "\n" (
            d:
            ''KERNEL=="card*", KERNELS=="${d.pciId}", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/${d.name}-card"''
          ) cfg.gpu.devices;
        })

        (lib.mkIf (cfg.gpu.vendor == "amd") {
          boot.initrd.kernelModules = [ "amdgpu" ];
          services.xserver.videoDrivers = [ "amdgpu" ];
          hardware.graphics.enable = true;
          hardware.graphics.enable32Bit = true;
        })

        (lib.mkIf (cfg.gpu.vendor == "nvidia") {
          services.xserver.videoDrivers = [ "nvidia" ];
          hardware.graphics.enable = true;
          hardware.nvidia = {
            modesetting.enable = true;
            open = true;
            package = config.boot.kernelPackages.nvidiaPackages.stable;
          };
        })

        (lib.mkIf (cfg.gpu.vendor == "intel") {
          services.xserver.videoDrivers = [ "modesetting" ];
          hardware.graphics = {
            enable = true;
            extraPackages = [ config.boot.kernelPackages.pkgs.intel-media-driver or null ];
          };
        })
      ];
    };

  flake.modules.homeManager.hardware =
    { ... }:
    {
      imports = [ ./options.nix ];
    };
}
