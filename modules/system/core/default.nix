{
  flake.modules.nixos.core = {
    programs.zsh.enable = true;

    nix = {
      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Keep the store from growing without bound.
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      optimise.automatic = true;
    };

    nixpkgs.config.allowUnfree = true;

    system.stateVersion = "26.05";
  };
}
