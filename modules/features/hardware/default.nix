{ lib, ... }:
{
  flake.modules.nixos.hardware =
    { config, ... }:
    let
      cfg = config.my.hardware;
    in
    {
      imports = [ ./options.nix ];
      config = lib.mkIf (cfg.gpuDevices != [ ]) {
        services.udev.extraRules = lib.concatMapStringsSep "\n"
          (d: ''KERNEL=="card*", KERNELS=="${d.pciId}", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/${d.name}-card"'')
          cfg.gpuDevices;
      };
    };

  flake.modules.homeManager.hardware =
    { ... }:
    { imports = [ ./options.nix ]; };
}
