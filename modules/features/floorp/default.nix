{ inputs, ... }:
{
  flake.modules.nixos.floorp =
    {
      config,
      lib,
      ...
    }:
    let
      desktopFile = "floorp.desktop";
    in
    {
      imports = [
        (inputs.nix-wrapper-modules.lib.getInstallModule {
          name = "floorp";
          value =
            {
              config,
              lib,
              wlib,
              pkgs,
              ...
            }:
            {
              imports = [ wlib.modules.default ];

              options = {
                policies = lib.mkOption {
                  inherit (pkgs.formats.json { }) type;
                  default = { };
                  description = "Enterprise policies written to policies.json (see about:policies).";
                };
                prefs = lib.mkOption {
                  type = lib.types.attrsOf (pkgs.formats.json { }).type;
                  default = { };
                  description = "Preferences locked into the browser via the autoconfig file.";
                };
              };

              config = {
                binName = "floorp";
                package = pkgs.floorp-bin.override {
                  extraPolicies = config.policies;
                  extraPrefs = lib.concatStringsSep "\n" (
                    lib.mapAttrsToList (n: v: "lockPref(${builtins.toJSON n}, ${builtins.toJSON v});") config.prefs
                  );
                };

                policies = {
                  DisableTelemetry = true;
                  DisableFirefoxStudies = true;
                  DisablePocket = true;
                  DontCheckDefaultBrowser = true;
                  NoDefaultBookmarks = true;
                  PasswordManagerEnabled = false;
                  OfferToSaveLogins = false;
                  ExtensionSettings = {
                    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
                      installation_mode = "force_installed";
                      install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
                    };
                    "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
                      installation_mode = "force_installed";
                      install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
                    };
                  };
                };

                prefs = {
                  "browser.aboutConfig.showWarning" = false;
                  "browser.shell.checkDefaultBrowser" = false;
                  "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
                  "widget.use-xdg-desktop-portal.file-picker" = 1;
                };
              };
            };
        })
      ];

      config = lib.mkIf (config.my.desktop.browser == "floorp") {
        wrappers.floorp.enable = true;

        my.desktop.browserCommand = lib.getExe config.wrappers.floorp.wrapper;

        environment.sessionVariables.BROWSER = "floorp";

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
    };
}
