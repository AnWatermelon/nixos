{
  flake.modules.nixos.xdg = _: {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config.common.default = "*";
    };

    xdg.terminal-exec = {
      enable = true;
      settings.default = [ "kitty.desktop" ];
    };
  };
}
