{ lib, ... }:
{
  options.my.hardware = {
    laptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this machine is a laptop";
    };
    gpu = lib.mkOption {
      type = lib.types.enum [
        "igpu"
        "dgpu"
        "hybrid"
      ];
      default = "dgpu";
      description = "'hybrid' = has a dGPU but should render Hyprland on the iGPU";
    };
     gpuDevices = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.strMatching "[a-z0-9-]+";
            description = "Colon-free friendly name, e.g. \"igpu\"";
          };
          pciId = lib.mkOption {
            type = lib.types.str;
            description = "PCI address from `lspci -D`, e.g. \"0000:c4:00.0\"";
          };
        };
      });
      default = [ ];
      example = [
        { name = "igpu"; pciId = "0000:c4:00.0"; }
        { name = "dgpu"; pciId = "0000:03:00.0"; }
      ];
      description = "GPUs to expose as stable /dev/dri/<name>-card symlinks, priority order (first = primary).";
    };
  };
}
