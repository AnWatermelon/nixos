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
      environment.systemPackages = [ pkgs.cifs-utils ];

      sops = {
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        secrets."smb-credentials" = {
          sopsFile = ./secrets/smb-credentials.yaml;
        };
      };

      fileSystems."/home/maxfh/shared" = {
        device = "//10.1.0.2/NAS/";
        fsType = "cifs";
        options =
          let
            automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=1000,gid=100";

          in
          [ "${automount_opts},credentials=${config.sops.secrets."smb-credentials".path}" ];
      };
    };
}
