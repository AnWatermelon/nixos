{ inputs, ... }:
{
  flake.modules.homeManager.zen-browser =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      zen = inputs.zen-browser.packages.${system}.default;
      desktopFile = "zen.desktop"; # confirmed via `ls .../share/applications/`
    in
    {
      imports = [ ../desktop/options.nix ];

      config = lib.mkIf (config.my.desktop.browser == "zen") {
        home.packages = [ zen ];
        my.desktop.browserCommand = lib.getExe zen;

        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "text/html" = desktopFile;
            "application/xhtml+xml" = desktopFile;
            "application/pdf" = desktopFile;
            "x-scheme-handler/http" = desktopFile;
            "x-scheme-handler/https" = desktopFile;
            "x-scheme-handler/about" = desktopFile;
            "x-scheme-handler/unknown" = desktopFile;
          };
        };

        home.sessionVariables.BROWSER = "zen";
      };
    };
}
