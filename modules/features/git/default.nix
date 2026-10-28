{
  flake.modules.nixos.git = {
    # core enables programs.git and adds safe.directory; this only adds to it.
    programs.git.config = {
      user = {
        name = "Max Hilton";
        email = "maxfhilton52@gmail.com";
        signingKey = "/home/maxfh/.ssh/id_ed25519.pub";
      };
      gpg.format = "ssh";
      commit.gpgSign = true;
      tag.gpgSign = true;
      pull.rebase = true;
    };
  };
}
