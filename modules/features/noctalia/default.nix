{ inputs, ... }:
{
  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      home.packages = [
        inputs.noctalia.packages.${pkgs.system}.default
      ];

      xdg.configFile = {
        "noctalia/settings.toml".source = ./settings.toml;
        "noctalia/user-templates.toml".source = ./user-templates.toml;
        "noctalia/templates/zsh-palette.conf".source = ./templates/zsh-palette.conf;
        "noctalia/templates/nvim-base16.lua".source = ./templates/nvim-base16.lua;
        "noctalia/templates/spotatui.yml".source = ./templates/spotatui.yml;
        "noctalia/templates/Translucence.theme.css".source = ./templates/Translucence.theme.css;
      };
    };
}
