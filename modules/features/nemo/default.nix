_: {
  flake.modules.nixos.nemo =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    lib.mkIf config.my.desktop.hyprland.enable {
      users.users.maxfh.packages = [
        pkgs.nemo-with-extensions
        pkgs.file-roller
        pkgs.vlc
        pkgs.unzip
        pkgs.zip
        pkgs.p7zip
        pkgs.unar
      ];

      programs.dconf.profiles.user.databases = [
        {
          settings."org/cinnamon/desktop/applications/terminal" = {
            exec = baseNameOf (lib.getExe config.my.terminal);
          };
        }
      ];

      # Order sets precedence when several apps handle the same mime type.
      my.desktop.defaultApplicationPackages = [
        config.my.neovim.package
        pkgs.libreoffice
        pkgs.vlc
        pkgs.file-roller
        pkgs.nemo
      ];
    };
}
