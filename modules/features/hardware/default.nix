{ lib, ... }:
{
  flake.modules.nixos.hardware =
    { config, pkgs, ... }:
    let
      cfg = config.my.hardware;
    in
    {
      imports = [ ./options.nix ];
      config = lib.mkMerge [
        {
          hardware = {
            uinput.enable = true;
            keyboard.qmk.keychronSupport = true;
          };

          services.udev.packages = [
            (pkgs.writeTextDir "lib/udev/rules.d/99-boxflat.rules" ''
              # Copyright (c) 2025, Tomasz Pakuła Using Arch BTW

              # Add uaccess tag to every Moza (Gudsen) ttyACM device so a user can easily access it
              # without being added to the uucp group. This in turn will make it so EVERY user
              # can access these devices
              SUBSYSTEM=="tty", KERNEL=="ttyACM*", ATTRS{idVendor}=="346e", ACTION=="add", MODE="0666", TAG+="uaccess"

              # Add uaccess tag to uinput devices to create virtual joysticks
              SUBSYSTEM=="misc", KERNEL=="uinput", OPTIONS+="static_node=uinput", TAG+="uaccess"
            '')
          ];
        }

        (lib.mkIf (cfg.powerDaemon == "tuned") {
          services.tuned.enable = true;
        })

        # nixos-hardware only enables PPD on AMD; Intel would fall back to TLP
        (lib.mkIf (cfg.powerDaemon == "ppd") {
          services.power-profiles-daemon.enable = true;
        })

        (lib.mkIf (cfg.gpu.devices != [ ]) {
          services.udev.extraRules = lib.concatMapStringsSep "\n" (
            d:
            ''KERNEL=="card*", KERNELS=="${d.pciId}", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/${d.name}-card"''
          ) cfg.gpu.devices;
        })

        (lib.mkIf (cfg.gpu.vendor == "amd") {
          boot.initrd.kernelModules = [ "amdgpu" ];
          services.xserver.videoDrivers = [ "amdgpu" ];
          nixpkgs.config.rocmSupport = true;
          hardware.graphics.enable = true;
          hardware.graphics.enable32Bit = true;
          environment.systemPackages = with pkgs; [
            rocmPackages.rocm-smi
            rocmPackages.rocminfo
          ];
          programs.corectrl.enable = true;
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
            extraPackages = [ pkgs.intel-media-driver ];
          };
        })
      ];
    };
}
