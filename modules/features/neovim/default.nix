{
  flake.modules.homeManager.neovim =
    { pkgs, ... }:
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        # home-manager owns init.lua so it can merge in its own plugin
        # scaffolding; everything of substance lives in the lua/ tree below.
        initLua = ''
          require("config.options")
          require("plugins")
        '';

        extraPackages = with pkgs; [
          ripgrep
          fd
          git
        ];

        # Plugins and treesitter grammars are pinned by nixpkgs and placed on the
        # packpath. No imperative bootstrap, and no lazy-lock.json that lazy.nvim
        # could never write to anyway (the config dir is a read-only store path).
        plugins = with pkgs.vimPlugins; [
          base16-nvim
          flash-nvim
          mini-nvim
          snacks-nvim
          which-key-nvim
          (nvim-treesitter.withPlugins (
            p: with p; [
              bash
              c
              cpp
              css
              diff
              git_config
              git_rebase
              gitcommit
              gitignore
              go
              html
              javascript
              json
              lua
              luadoc
              make
              markdown
              markdown_inline
              nix
              python
              query
              regex
              rust
              toml
              tsx
              typescript
              vim
              vimdoc
              yaml
            ]
          ))
        ];
      };

      xdg.configFile."nvim/lua".source = ./lua;
    };
}
