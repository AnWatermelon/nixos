{
  flake.modules.nixos.nas =
    {
      config,
      inputs,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      programs.fuse.enable = true;
      environment.systemPackages = [ pkgs.rclone ];

      sops = {
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        secrets."rclone-nas-conf" = {
          sopsFile = ./secrets/rclone-nas-conf.yaml;
          owner = "maxfh";
        };
      };

      systemd.tmpfiles.rules = [
        "d /home/maxfh/shared 0755 maxfh users -"
        "d /home/maxfh/.cache/rclone 0700 maxfh users -"
      ];

      systemd.services.rclone-nas = {
        description = "rclone mount of NAS share with local VFS cache";
        after = [
          "network-online.target"
          "netbird-wt0.service"
        ];
        requires = [ "netbird-wt0.service" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        path = [ "/run/wrappers" ];

        environment.RCLONE_CONFIG = config.sops.secrets."rclone-nas-conf".path;

        serviceConfig = {
          Type = "notify";
          User = "maxfh";
          Group = "users";
          ExecStart = ''
            ${pkgs.rclone}/bin/rclone mount nas:NAS /home/maxfh/shared \
              --vfs-cache-mode full \
              --vfs-cache-max-age 720h \
              --dir-cache-time 1h \
              --cache-dir /home/maxfh/.cache/rclone \
              --umask 022
          '';
          ExecStop = "/run/wrappers/bin/fusermount3 -u /home/maxfh/shared";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };
}
