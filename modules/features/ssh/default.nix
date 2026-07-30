{
  flake.modules.homeManager.ssh = {
    services.ssh-agent.enable = true;
    programs.ssh = {
      enable = true;
      settings."*".addKeysToAgent = "yes";
    };
  };
}
