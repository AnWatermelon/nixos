{
  flake.modules.homeManager.neovim =
    { pkgs, ... }:
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        initLua = ''
                    require("config.options")
                    require("plugins")
        '';

        extraPackages = with pkgs; [
          ripgrep
          fd
          git

          bash-language-server
          clang-tools # clangd for C/C++
          dockerfile-language-server-nodejs
          gopls
          lua-language-server
          marksman # Markdown
          nil # Nix (fast, single-file)
          nixd # Nix (full-featured, flakes/projects)
          pyright
          rust-analyzer
          taplo # TOML
          typescript-language-server
          vscode-langservers-extracted # html, css, json, eslint
          yaml-language-server
        ];

        plugins = with pkgs.vimPlugins; [
          base16-nvim
          flash-nvim
          mini-nvim
          nvim-lspconfig
          snacks-nvim
          which-key-nvim
          lualine-nvim
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
