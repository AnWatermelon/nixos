{
  flake.modules.nixos.gitea = { inputs, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      secrets."gitea-ssh-key" = {
        sopsFile = ./secrets/gitea-ssh-key.yaml;
        path = "/etc/gitea/id_ed25519";
        owner = "root";
        group = "wheel";
        mode = "0640";
      };
    };

    programs.ssh = {
      extraConfig = ''
        Host gitea.hilton-tech.net
          HostName 10.1.0.14
          User gitea
          Port 22
          IdentityFile /etc/gitea/id_ed25519
          IdentitiesOnly yes
      '';
      knownHosts = {
        "gitea.hilton-tech.net" = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhcQyzkGDdjHpFYvhhZLf/EW8oPrkCwgtgKB6CVTsdK";
          extraHostNames = [ "10.1.0.14" ];
        };
      };
    };
  };
}
