{
  flake.modules.nixos.cage =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.cage;
    in
    {
      options.my.cage = {
        enable = lib.mkEnableOption "cage kiosk session — boots greetd with a TUI login, then a fullscreen terminal on tty1";
        user = lib.mkOption {
          type = lib.types.str;
          default = "maxfh";
          description = "Default user for the cage session (used if initial_session auto-login is configured).";
        };
      };

      config = lib.mkIf cfg.enable {
        hardware.graphics.enable = lib.mkDefault true;
        security.polkit.enable = true;

        services.greetd = {
          enable = true;
          useTextGreeter = true;
          settings = {
            default_session = {
              command = "${lib.getExe pkgs.tuigreet} --time --asterisks --remember --cmd '${lib.getExe pkgs.cage} -- ${lib.getExe config.my.terminal}'";
              user = "greeter";
            };
          };
        };
      };
    };
}
