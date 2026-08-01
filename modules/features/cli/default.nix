{ config, pkgs, inputs, ... }:
{
  config.flake.modules.homeManager.cli = { pkgs, inputs, ... }: {
    home.packages = with pkgs; [
      fastfetch
      btop
      nerd-fonts.jetbrains-mono
      neovim
    ] ++ [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
