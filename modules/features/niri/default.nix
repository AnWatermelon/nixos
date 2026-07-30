{ config, ... }:
{
  config.flake.modules.homeManager.niri = { ... }: {
    programs.niri.enable = true;
  };
}
