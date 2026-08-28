{ lib, ... }:
{
  options.my.hardware = {
    laptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this machine is a laptop";
    };
    gpu = lib.mkOption {
      type = lib.types.enum [ "igpu" "dgpu" "hybrid" ];
      default = "dgpu";
      description = "'hybrid' = has a dGPU but should render Hyprland on the iGPU";
    };
    gpuPciIds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "0000:65:00.0" "0000:04:00.0" ];
      description = ''
        PCI bus IDs (from `lspci -d ::03xx`) for AQ_DRM_DEVICES,
        in priority order — iGPU first. Only used when gpu != "dgpu".
      '';
    };
  };
}
