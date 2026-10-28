{ inputs, ... }:
{
  flake.modules.nixos.core = _: {
    # Ties each generation to the commit it was built from
    # (`nixos-version --configuration-revision`).
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        extra-substituters = [
          "http://cache.hilton-tech.net:5000?priority=30"
        ];
        extra-trusted-public-keys = [
          "cache.hilton-tech.net-1:W3bx/PWbJiyn95ibErTD9olBiaLaLvwsk7bQMN2hXLo="
        ];
      };

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
