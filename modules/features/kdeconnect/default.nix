_: {
  flake.modules.nixos.kdeconnect =
    { pkgs, ... }:
    {
      programs.kdeconnect.enable = true;

      environment.systemPackages = [
        pkgs.glib
        pkgs.sshfs
      ];
    };
}
