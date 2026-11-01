{
  flake.modules.nixos.xdg =
    { config, lib, ... }:
    let
      # Desktop entry IDs for terminals that don't ship "<pname>.desktop".
      desktopIds = {
        ghostty = "com.mitchellh.ghostty.desktop";
      };
      terminalName = lib.getName config.my.terminal;
    in
    {
      # No catch-all config.common: /etc/xdg/xdg-desktop-portal/portals.conf
      # is found before the $desktop-portals.conf each desktop ships (via
      # xdg.portal.configPackages), so it would override all of them.
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
      };

      xdg.terminal-exec = {
        enable = true;
        settings.default = [ (desktopIds.${terminalName} or "${terminalName}.desktop") ];
      };
    };
}
