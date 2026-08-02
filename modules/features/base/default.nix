{
  flake.modules.homeManager.base =
    { config, ... }:
    {
      home = {
        username = "maxfh";
        homeDirectory = "/home/${config.home.username}";
        stateVersion = "26.05";
        enableNixpkgsReleaseCheck = false;
      };

      programs.home-manager.enable = true;
    };
}
