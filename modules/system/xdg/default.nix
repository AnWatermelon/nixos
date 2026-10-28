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
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        config.common.default = "*";
      };

      xdg.terminal-exec = {
        enable = true;
        settings.default = [ (desktopIds.${terminalName} or "${terminalName}.desktop") ];
      };
    };
}
