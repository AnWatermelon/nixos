{
  flake.modules.homeManager.ssh = {
    services.ssh-agent.enable = true;
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*".addKeysToAgent = "yes";
      matchBlocks."gitea.hilton-tech.net" = {
        hostname = "10.1.0.14";
	user = "gitea";
	port = 22;
	identityFile = "~/.ssh/id_ed25519";
	identitiesOnly = true;
      };
    };
  };
}
