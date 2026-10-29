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
        autoLogin = lib.mkEnableOption "logging ${cfg.user} straight into the cage session at boot, skipping the greeter";
      };

      config = lib.mkIf cfg.enable (
        let
          # -s allows switching to other VTs.
          session = "${lib.getExe pkgs.cage} -s -- ${lib.getExe config.my.terminal}";
        in
        {
          hardware.graphics.enable = lib.mkDefault true;
          security.polkit.enable = true;

          services.greetd = {
            enable = true;
            useTextGreeter = true;
            settings = {
              default_session = {
                command = "${lib.getExe pkgs.tuigreet} --time --asterisks --remember --cmd '${session}'";
                user = "greeter";
              };
              # Runs once per boot; exiting it falls back to the greeter.
              initial_session = lib.mkIf cfg.autoLogin {
                command = session;
                inherit (cfg) user;
              };
            };
          };
        }
      );
    };
}
