{ ... }:
{
  flake.modules.homeManager.nemo =
    { pkgs, config, ... }:
    {
      home.packages = [
        pkgs.nemo
        pkgs.vlc
      ];
      services = {
        gvfs.enable = true;
        udisks2.enable = true;
      };
      xdg.mimeApps = {
        enable = true;
        defaultApplicationPackages = [
          config.programs.neovim.finalPackage
          pkgs.libreoffice
          pkgs.vlc
          pkgs.nemo
        ];
      };
    };
}
