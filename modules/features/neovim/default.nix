{ inputs, ... }:
{
  flake.modules.nixos.neovim =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # init.lua lives in a store directory next to ./lua so the wrapper never
      # looks at ~/.config/nvim.
      configDirectory = pkgs.linkFarm "nvim-config" [
        {
          name = "init.lua";
          path = pkgs.writeText "init.lua" ''
            vim.g.loaded_node_provider = 0
            vim.g.loaded_perl_provider = 0
            vim.g.loaded_ruby_provider = 0
            vim.g.loaded_python3_provider = 0
            require("config.options")
            require("plugins")
          '';
        }
        {
          name = "lua";
          path = ./lua;
        }
      ];

      neovim = inputs.nix-wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;

        settings = {
          config_directory = configDirectory;
          aliases = [
            "vi"
            "vim"
          ];
        };

        # HM turned the remote-plugin providers off
        hosts = {
          node.nvim-host.enable = false;
          ruby.nvim-host.enable = false;
        };

        # nvim's PATH only, not global
        runtimePkgs =
          with pkgs;
          [
            ripgrep
            fd
            git

            bash-language-server
            dockerfile-language-server
            gopls
            lua-language-server
            nil # Nix (fast, single-file)
            nixd # Nix (full-featured, flakes/projects)
            pyright
            taplo # TOML
            typescript-language-server
            vscode-langservers-extracted # html, css, json, eslint
            yaml-language-server
          ]
          ++ lib.optionals (!config.my.neovim.lean) [
            clang-tools # clangd for C/C++ (~1.3 GiB with clang and gcc)
            marksman # Markdown (pulls in the .NET runtime)
            rust-analyzer
          ];

        specs.plugins = with pkgs.vimPlugins; [
          base16-nvim
          blink-cmp
          flash-nvim
          mini-nvim
          nui-nvim
          noice-nvim
          nvim-lspconfig
          lazydev-nvim
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
    in
    {
      options.my.neovim.lean = lib.mkEnableOption "a lighter neovim without the clangd, marksman and rust-analyzer language servers";

      options.my.neovim.package = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        default = neovim;
        description = "The wrapped neovim package.";
      };

      config = {
        environment = {
          systemPackages = [ config.my.neovim.package ];
          sessionVariables = {
            EDITOR = "nvim";
            VISUAL = "nvim";
          };
        };

        my.dotfiles.files.".config/matugen/templates/nvim-base16.lua".source = ./matugen-template.lua;
      };
    };
}
