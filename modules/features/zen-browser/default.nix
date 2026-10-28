{ inputs, ... }:
{
  flake.modules.nixos.zen-browser =
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
    lib.mkIf (config.my.desktop.browser == "zen") {
      my.desktop.browserCommand = lib.getExe zen;

      environment = {
        systemPackages = [ zen ];
        sessionVariables.BROWSER = "zen";
      };

      xdg.mime.defaultApplications = {
        "text/html" = desktopFile;
        "application/xhtml+xml" = desktopFile;
        "application/pdf" = desktopFile;
        "x-scheme-handler/http" = desktopFile;
        "x-scheme-handler/https" = desktopFile;
        "x-scheme-handler/about" = desktopFile;
        "x-scheme-handler/unknown" = desktopFile;
      };
    };
}
