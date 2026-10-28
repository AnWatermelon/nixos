_: {
  # Vivaldi reads Chromium-style enterprise policies from /etc/vivaldi/policies/managed,
  # which is only writable from the system config.
  flake.modules.nixos.vivaldi =
    { config, lib, ... }:
    lib.mkIf (config.my.desktop.browser == "vivaldi") {
      environment.etc."vivaldi/policies/managed/nix.json".text = builtins.toJSON {
        ExtensionInstallForcelist = [
          "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx" # Bitwarden
          "dbepggeogbaibhgnhhndojpepiihcmeb;https://clients2.google.com/service/update2/crx" # Vimium
        ];
        DefaultBrowserSettingEnabled = false;
        PromotionalTabsEnabled = false;
      };
    };

  flake.modules.homeManager.vivaldi =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      desktopFile = "vivaldi-stable.desktop";
      vivaldi = pkgs.vivaldi.override {
        commandLineArgs = "--force-dark-mode --enable-features=WebContentsForceDark";
      };
    in
    {
      imports = [ ../desktop/options.nix ];

      config = lib.mkIf (config.my.desktop.browser == "vivaldi") {
        home.packages = [ vivaldi ];
        my.desktop.browserCommand = lib.getExe vivaldi;

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

        home.sessionVariables.BROWSER = "vivaldi";
      };
    };
}
