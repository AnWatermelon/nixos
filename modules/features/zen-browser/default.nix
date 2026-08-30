{ inputs, ... }:
{
  flake.modules.homeManager.zen-browser =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      zen = inputs.zen-browser.packages.${system}.default;
      desktopFile = "zen.desktop"; # confirmed via `ls .../share/applications/`
    in
    {
      home.packages = [ zen ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = desktopFile;
          "application/xhtml+xml" = desktopFile;
          "x-scheme-handler/http" = desktopFile;
          "x-scheme-handler/https" = desktopFile;
          "x-scheme-handler/about" = desktopFile;
          "x-scheme-handler/unknown" = desktopFile;
        };
      };

      home.sessionVariables.BROWSER = "zen";
    };
}
