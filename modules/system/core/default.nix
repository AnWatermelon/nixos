{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
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

      systemd.services.lock-root = {
        description = "Lock the root account after the final system's first boot";
        wantedBy = [ "multi-user.target" ];
        unitConfig.ConditionPathExists = [
          "/etc/root-lock-pending"
          "!/var/lib/root-locked"
        ];
        serviceConfig.Type = "oneshot";
        path = [ pkgs.shadow ];
        script = ''
          passwd -l root
          rm -f /etc/root-lock-pending
          touch /var/lib/root-locked
        '';
      };
    };
}
