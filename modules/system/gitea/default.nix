{
  flake.modules.nixos.gitea = { inputs, pkgs, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    # root needs the ssh client to git-fetch the Gitea origin (the origin
    # remote is an SSH URL); without this, `git fetch`/`git pull` in
    # /etc/nixos dies with "cannot run ssh: No such file or directory".
    environment.systemPackages = [ pkgs.openssh ];

    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      secrets."gitea-ssh-key" = {
        sopsFile = ./secrets/gitea-ssh-key.yaml;
        path = "/etc/gitea/id_ed25519";
        owner = "maxfh";
        group = "root";
        mode = "0600";
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
