{
  flake.modules.homeManager.zsh = {
    programs.zsh = {
      enable = true;
      enableCompletion = false;
      localVariables = {
        DISABLE_AUTO_UPDATE = "true";
        DISABLE_MAGIC_FUNCTIONS = "true";
        VI_MODE_SET_CURSOR = "true";
        KEYTIMEOUT = "10";
        ZSH_DISABLE_COMPFIX = "true";
        skip_global_compinit = "1";
      };
      shellAliases = {
        sp = "spotatui";
        cfg = "cd ~/.config/";
        lg = "lazygit";
        p = "cd ~/Projects";
        s = "cd ~/shared/Documents/School";
        nrb = "sudo nixos-rebuild switch --flake /home/maxfh/Projects/nixos";
        hms = "home-manager switch --flake ~/Projects/nixos#maxfh";
        nfc = "nix flake check && nix formatter run";
        tdu = "sudo ncdu --exclude '/.snapshots' --exclude '/mnt' /";
        nbs = "sudo netbird-wt0 status -d";
        nbd = "sudo netbird-wt0 down";
        nbu = "sudo netbird-wt0 up";
        nbr = "sudo netbird-wt0 down && sudo netbird-wt0 up";
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
