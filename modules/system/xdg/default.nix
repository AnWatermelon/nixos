{
  flake.modules.nixos.xdg = _: {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config.common.default = "*";
    };
  };
}
