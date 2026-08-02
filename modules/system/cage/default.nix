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
        enable = lib.mkEnableOption "cage kiosk session — boots to a fullscreen terminal on tty1";
        user = lib.mkOption {
          type = lib.types.str;
          default = "maxfh";
          description = "User auto-logged in for the cage session.";
        };
      };

      config = lib.mkIf cfg.enable {
        services.cage = {
          enable = true;
          inherit (cfg) user;
          program = "${lib.getExe config.my.terminal} -e ${lib.getExe' pkgs.shadow.su "su"} -l ${cfg.user}";
        };
      };
    };
}
