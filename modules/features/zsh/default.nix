{ config, ... }:
{
  config.flake.modules.homeManager.zsh = { ... }: {
    programs.zsh.enable = true;
  };
}
