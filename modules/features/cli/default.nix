{ config, inputs, ... }:
let
  flakeCfg = config;
in
{
  flake.modules.nixos.cli =
    { config, pkgs, ... }:
    {
      imports = [
        flakeCfg.flake.modules.nixos.neovim
        flakeCfg.flake.modules.nixos.git
        flakeCfg.flake.modules.nixos.ssh
      ];
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      # no clean.enable: core's nix.gc keeps 30 days of generations for rollback.
      programs.nh = {
        enable = true;
        flake = config.my.dotfiles.flakePath;
      };
      fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
      users.users.maxfh.packages = with pkgs; [
        fastfetch
        btop
        lazygit
        ncdu
        nmap
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
        fzf
        nix-search-tv
        nodejs
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
      ];
    };

  flake.modules.homeManager.cli = _: {
    imports = [
      flakeCfg.flake.modules.homeManager.zsh
      flakeCfg.flake.modules.homeManager.tmux
    ];
  };
}
