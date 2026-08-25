{ lib, ... }:
{
  options.my.desktop = {
    environment = lib.mkOption {
      type = lib.types.enum [
        "hyprland"
        "niri"
        "gnome"
      ];
      default = "hyprland";
      description = "Desktop environment/window manager to use";
    };
  };
}
