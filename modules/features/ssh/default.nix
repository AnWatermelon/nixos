{
  flake.modules.homeManager.ssh = {
    services.ssh-agent.enable = true;
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*".addKeysToAgent = "yes";
        "gitea" = {
          hostname = "10.1.0.14";
          user = "gitea";
          port = 22;
          identityFile = "/etc/gitea/id_ed25519";
          identitiesOnly = true;
        };
        "pve-1" = {
          hostname = "10.1.3.1";
          user = "root";
        };
        "pve-2" = {
          hostname = "10.1.3.2";
          user = "root";
        };
      };
    };
  };
}
