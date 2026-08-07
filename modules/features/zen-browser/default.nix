{ inputs, ... }:
{
  flake.modules.homeManager.zen-browser =
    { pkgs, ... }:
    {
      home.packages = [
        inputs.zen-browser.packages.${pkgs.system}.zen-browser
      ];
    };
}
