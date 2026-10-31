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
      user = "maxfh";
      # GNOME brings gdm, so greetd only runs for the other desktops.
      sessions =
        lib.optional desktop.hyprland.enable "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop"
        ++ lib.optional desktop.niri.enable "${config.programs.niri.package}/bin/niri-session";
      enabled = !desktop.gnome.enable && sessions != [ ];
      sessionDir = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
    in
    {
      services.greetd = {
        enable = lib.mkDefault enabled;
        useTextGreeter = true;
        settings = lib.mkIf enabled {
          # With a single desktop, log straight in at boot; the greeter only
          # shows up after logging out. With several, pick from the greeter.
          initial_session = lib.mkIf (lib.length sessions == 1) {
            command = lib.head sessions;
            inherit user;
          };
          default_session = {
            command = "${lib.getExe pkgs.tuigreet} --time --asterisks --remember --remember-session --sessions ${sessionDir}";
            user = "greeter";
          };
        };
      };
    };
}
