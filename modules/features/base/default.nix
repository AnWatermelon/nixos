{
  flake.modules.homeManager.base = {
    home.username = "maxfh";
    home.homeDirectory = "/home/maxfh";
    home.stateVersion = "26.05";
    home.enableNixpkgsReleaseCheck = false;
    programs.home-manager.enable = true;
  };
}
