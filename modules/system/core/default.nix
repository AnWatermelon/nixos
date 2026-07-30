{ config, ... }:
{
  config.flake.modules.nixos.core = { ... }: {
    programs.zsh.enable = true;
    nixpkgs.config.allowUnfree = true;
    system.stateVersion = "26.05";
  };
}
