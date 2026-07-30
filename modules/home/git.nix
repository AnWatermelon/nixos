{
  flake.modules.homeManager.git = {
    programs.git = {
      enable = true;
      signing.signByDefault = true;
      signing.key = "/home/maxfh/.ssh/id_ed25519.pub";
      settings = {
        gpg.format = "ssh";
        user = {
          name = "Max Hilton";
          email = "maxfhilton52@gmail.com";
        };
      };
    };
  };
}
