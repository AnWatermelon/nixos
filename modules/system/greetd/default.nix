_: {
  flake.modules.nixos.greetd =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      desktop = config.my.desktop;
      # GNOME brings gdm, so greetd only runs for the other desktops.
      enabled = !desktop.gnome.enable && (desktop.hyprland.enable || desktop.niri.enable);
      command =
        if desktop.hyprland.enable then
          "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop"
        else
          "${config.programs.niri.package}/bin/niri-session";
    in
    {
      services.greetd = {
        enable = lib.mkDefault enabled;
        settings.default_session = lib.mkIf enabled {
          inherit command;
          user = "maxfh";
        };
      };
    };
}
