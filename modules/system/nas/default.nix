{
  flake.modules.nixos.nas =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.cifs-utils ];
      fileSystems."/home/maxfh/shared" = {
        device = "//10.1.0.2/NAS/";
        fsType = "cifs";
        options =
          let
            automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

          in
          [ "${automount_opts},credentials=/etc/nixos/smb-secrets" ];
      };
    };
}
