{ inputs, ... }:
{
  flake.modules.homeManager.noctalia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.my.noctalia = {
        package = lib.mkOption {
          type = lib.types.package;
          default = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
          description = "The noctalia package to install.";
        };
      };

      imports = [
        ../hardware/options.nix
      ];

      config = {
        home.packages = [ config.my.noctalia.package ];

        xdg.configFile = {
          "noctalia/settings.toml".source = ./settings.toml;
          "noctalia/user-templates.toml".source = ./user-templates.toml;
          "noctalia/templates/zsh-palette.conf".source = ./templates/zsh-palette.conf;
          "noctalia/templates/nvim-base16.lua".source = ./templates/nvim-base16.lua;
          "noctalia/templates/spotatui.yml".source = ./templates/spotatui.yml;
          "noctalia/templates/Translucence.theme.css".source = ./templates/Translucence.theme.css;
          "noctalia/laptop.toml" = lib.mkIf config.my.hardware.laptop {
            source = ./laptop.toml;
          };
        };
      };
    };
}
