_: {
  flake.modules.homeManager.nemo =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    lib.mkIf (config.my.desktop.environment == "hyprland") {
      home.packages = [
        pkgs.nemo-with-extensions
        pkgs.file-roller
        pkgs.vlc

        pkgs.unzip
        pkgs.zip
        pkgs.p7zip
        pkgs.unar
      ];
      xdg.mimeApps = {
        enable = true;
        defaultApplicationPackages = [
          config.programs.neovim.finalPackage
          pkgs.libreoffice
          pkgs.vlc
          pkgs.file-roller
          pkgs.nemo
        ];
      };
    };
}
