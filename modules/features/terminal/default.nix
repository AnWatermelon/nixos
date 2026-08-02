{
  flake.modules.homeManager.terminal =
    { lib, pkgs, ... }:
    {
      options.my.terminal = lib.mkOption {
        type = lib.types.package;
        default = pkgs.kitty;
        description = "Default terminal";
      };
    };
}
