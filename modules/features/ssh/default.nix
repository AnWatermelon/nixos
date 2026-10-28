{
  flake.modules.nixos.ssh =
    { config, ... }:
    {
      programs.ssh = {
        # gnome enables gcr's ssh agent, which asserts it is the only agent.
        startAgent = !config.services.gnome.gcr-ssh-agent.enable;
        extraConfig = ''
          Host gitea
            hostname 10.1.0.14
            user gitea
            port 22
            identityFile /etc/gitea/id_ed25519
            identitiesOnly yes

          Host pve-1
            hostname 10.1.3.1
            user root

          Host pve-2
            hostname 10.1.3.2
            user root

          Host *
            addKeysToAgent yes
        '';
      };
    };
}
