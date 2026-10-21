{
  flake.modules.nixos.core = _: {
    nix = {
      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      optimise.automatic = true;
    };

    services = {
      upower.enable = true;
      tuned.enable = true;
      fwupd.enable = true;
    };

    nixpkgs.config.allowUnfree = true;

    programs = {
      appimage = {
        enable = true;
        binfmt = true;
      };
      zsh.enable = true;
      git = {
        enable = true;
        config.safe.directory = [ "/etc/nixos" ];
      };
    };

    system.stateVersion = "26.05";

  };
}
