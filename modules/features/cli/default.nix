{ config, ... }:
let
  flakeCfg = config;
in
{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {
      imports = [
        flakeCfg.flake.modules.homeManager.neovim
        flakeCfg.flake.modules.homeManager.git
        flakeCfg.flake.modules.homeManager.ssh
        flakeCfg.flake.modules.homeManager.zsh
      ];
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      home.packages = with pkgs; [
        fastfetch
        btop
        nerd-fonts.jetbrains-mono
        lazygit
        ncdu
        nmap
        direnv
      ];
    };
}
