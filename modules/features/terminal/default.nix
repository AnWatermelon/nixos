{ config, ... }:
let
  flakeCfg = config;
in
{
  flake.modules.homeManager.terminal =
    { pkgs, lib, ... }:
    {
      imports = [
        flakeCfg.flake.modules.homeManager.kitty
      ];

      options.my.terminal = lib.mkOption {
        type = lib.types.package;
        default = pkgs.kitty;
        description = "Default terminal";
      };
    };
}
