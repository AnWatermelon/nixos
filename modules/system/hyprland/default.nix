{ config, ... }:
{
  config.flake.modules.nixos.hyprland = { ... }: {
    programs.hyprland.enable = true;
  };
}
