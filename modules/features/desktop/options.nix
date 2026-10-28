{ lib, ... }:
{
  options.my.desktop = {
    browser = lib.mkOption {
      type = lib.types.enum [
        "zen"
        "vivaldi"
      ];
      default = "vivaldi";
      description = "Default web browser";
    };
    browserCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command that launches the selected browser (set by the browser module)";
    };
    defaultApplicationPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = ''
        Packages whose .desktop files provide default mime associations, after
        the explicit xdg.mime.defaultApplications. Earlier packages win.
      '';
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
