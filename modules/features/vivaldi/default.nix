_: {
  flake.modules.nixos.vivaldi =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      desktopFile = "vivaldi-stable.desktop";
      vivaldi = pkgs.vivaldi.override {
        commandLineArgs = "--force-dark-mode --enable-features=WebContentsForceDark";
      };
    in
    lib.mkIf (config.my.desktop.browser == "vivaldi") {
      my.desktop.browserCommand = lib.getExe vivaldi;

      environment = {
        systemPackages = [ vivaldi ];
        sessionVariables.BROWSER = "vivaldi";

        # Vivaldi reads Chromium-style enterprise policies from /etc/vivaldi/policies/managed.
        etc."vivaldi/policies/managed/nix.json".text = builtins.toJSON {
          ExtensionInstallForcelist = [
            "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx" # Bitwarden
            "dbepggeogbaibhgnhhndojpepiihcmeb;https://clients2.google.com/service/update2/crx" # Vimium
          ];
          DefaultBrowserSettingEnabled = false;
          PromotionalTabsEnabled = false;
        };
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
