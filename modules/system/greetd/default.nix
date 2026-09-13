_: {
  flake.modules.nixos.greetd =
    { pkgs, lib, ... }:
    {
      services.greetd = {
        enable = lib.mkDefault false;
        settings = {
          default_session = {
            command = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
            user = "maxfh";
          };
        };
      };
    };
}
