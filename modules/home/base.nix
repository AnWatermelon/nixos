{
  flake.modules.homeManager.base = {
    home.username = "maxfh";
    home.homeDirectory = "/home/maxfh";
    home.stateVersion = "26.05";
    programs.home-manager.enable = true;
  };
}
