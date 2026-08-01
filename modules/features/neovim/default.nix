{
  flake.modules.homeManager.neovim = { pkgs, ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      sideloadInitLua = true;
      extraPackages = with pkgs; [
        ripgrep
        fd
        git
      ];
    };

    xdg.configFile = {
      "nvim/init.lua".source = ./init.lua;
      "nvim/lua/config/options.lua".source = ./lua/config/options.lua;
      "nvim/lua/config/lazy.lua".source = ./lua/config/lazy.lua;
      "nvim/lua/plugins/base16.lua".source = ./lua/plugins/base16.lua;
      "nvim/lua/plugins/flash.lua".source = ./lua/plugins/flash.lua;
      "nvim/lua/plugins/mini.lua".source = ./lua/plugins/mini.lua;
      "nvim/lua/plugins/snacks.lua".source = ./lua/plugins/snacks.lua;
      "nvim/lua/plugins/whichkey.lua".source = ./lua/plugins/whichkey.lua;
      "nvim/lua/matugen.lua".source = ./lua/matugen.lua;
      "nvim/lazy-lock.json".source = ./lazy-lock.json;
      "nvim/stylua.toml".source = ./stylua.toml;
      "nvim/.gitignore".source = ./gitignore;
    };
  };
}
