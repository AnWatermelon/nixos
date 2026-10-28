{ lib, ... }:
{
  options.my.desktop = {
    browser = lib.mkOption {
      type = lib.types.enum [
        "zen"
      ];
      default = "zen";
      description = "Default web browser";
    };
    browserCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command that launches the selected browser (set by the browser module)";
    };
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
