_: {
  flake.modules.nixos.greetd =
    { pkgs, ... }:
    {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
            user = "maxfh";
          };
        };
      };
    };
}
