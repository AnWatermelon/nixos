_: {
  flake.modules.nixos.kde =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.desktop.kde;
      chrome = pkgs.google-chrome;
      desktopFile = "google-chrome.desktop";
    in
    {
      options.my.desktop.kde = {
        enable = lib.mkEnableOption "the KDE Plasma desktop (brings its own display manager, Plasma Login Manager)";
        defaultUser = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            User preselected in the login screen, along with the Plasma
            session. Picking another user switches to their last session.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.defaultUser == null || config.users.users ? ${cfg.defaultUser};
            message = "my.desktop.kde.defaultUser: no user named ${toString cfg.defaultUser}";
          }
          {
            assertion = !config.my.desktop.gnome.enable;
            message = "my.desktop.kde and my.desktop.gnome each bring their own display manager; enable only one";
          }
        ];

        services = {
          desktopManager.plasma6.enable = true;
          displayManager.plasma-login-manager = {
            enable = true;
            settings.Greeter = lib.mkIf (cfg.defaultUser != null) {
              PreselectedUser = cfg.defaultUser;
              PreselectedSession = "plasma.desktop";
            };
          };
        };

        environment.etc = {
          # Chrome is the browser in Plasma only. Desktop-specific lists win
          # over /etc/xdg/mimeapps.list, which keeps my.desktop.browser for
          # the other desktops.
          "xdg/kde-mimeapps.list".text = lib.generators.toINI { } {
            "Default Applications" = lib.genAttrs [
              "text/html"
              "application/xhtml+xml"
              "application/pdf"
              "x-scheme-handler/http"
              "x-scheme-handler/https"
              "x-scheme-handler/about"
              "x-scheme-handler/unknown"
            ] (_: desktopFile);
          };

          # startplasma sources these after the session variables, so this
          # overrides the BROWSER set by the browser module.
          "xdg/plasma-workspace/env/browser.sh".text = ''
            export BROWSER=${lib.getExe chrome}
          '';
        };
      };
    };
}
