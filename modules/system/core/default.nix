{
  flake.modules.nixos.core = {
    programs.zsh.enable = true;

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

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    nixpkgs.config.allowUnfree = true;

    programs.git = {
      enable = true;
      config.safe.directory = [ "/etc/nixos" ];
    };

    system.stateVersion = "26.05";
  };
}
