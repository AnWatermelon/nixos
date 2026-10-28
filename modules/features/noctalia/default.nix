{ inputs, ... }:
{
  flake.modules.nixos.noctalia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.my.noctalia.package = lib.mkOption {
        type = lib.types.package;
        default = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        description = "The noctalia package to install.";
      };

      config = {
        environment.systemPackages = [ config.my.noctalia.package ];

        # The GUI writes its overrides to ~/.local/state/noctalia, so the base
        # files can stay read-only.
        my.dotfiles.files = {
          ".config/noctalia/settings.toml".source = ./settings.toml;
          ".config/noctalia/user-templates.toml".source = ./user-templates.toml;
          ".config/noctalia/templates/zsh-palette.conf".source = ./templates/zsh-palette.conf;
          ".config/noctalia/templates/nvim-base16.lua".source = ./templates/nvim-base16.lua;
          ".config/noctalia/templates/spotatui.yml".source = ./templates/spotatui.yml;
          ".config/noctalia/templates/Translucence.theme.css".source = ./templates/Translucence.theme.css;
          ".config/noctalia/laptop.toml" = {
            enable = config.my.hardware.laptop;
            source = ./laptop.toml;
          };
        };
      };
    };
}
