{
  flake.modules.homeManager.git =
    { config, ... }:
    {
      programs.git = {
        enable = true;
        signing.signByDefault = true;
        signing.key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        settings = {
          gpg.format = "ssh";
          user = {
            name = "Max Hilton";
            email = "maxfhilton52@gmail.com";
          };
          pull.rebase = true;
        };
      };
    };
}
