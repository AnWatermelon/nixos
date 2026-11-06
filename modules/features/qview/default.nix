_: {
  flake.modules.nixos.qview =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    lib.mkIf (config.my.desktop.hyprland.enable || config.my.desktop.niri.enable) {
      users.users.maxfh.packages = [ pkgs.qview ];

      # mkBefore so it wins over other packages that claim image types.
      my.desktop.defaultApplicationPackages = lib.mkBefore [ pkgs.qview ];
    };
}
