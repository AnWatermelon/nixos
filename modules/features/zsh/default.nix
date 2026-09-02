{
  flake.modules.homeManager.zsh = {
    programs.zsh = {
      enable = true;
      localVariables.VI_MODE_SET_CURSOR = "true";
      localVariables.KEYTIMEOUT = "10";
      shellAliases = {
        sp = "spotatui";
        cfg = "cd ~/.config/";
        lg = "lazygit";
        p = "cd ~/Projects";
        nrb = "sudo nixos-rebuild switch --flake /home/maxfh/Projects/nixos";
        hms = "home-manager switch --flake ~/Projects/nixos#maxfh";
        nfc = "nix flake check && nix formatter run";
        tdu = "sudo ncdu --exclude '/.snapshots' --exclude '/mnt' /";
      };
      oh-my-zsh = {
        enable = true;
        theme = "gnzh";
        plugins = [
          "vi-mode"
        ];
      };
      initContent = builtins.readFile ./init.zsh;
    };
  };
}
