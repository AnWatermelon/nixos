{
  flake.modules.home-manager.steam =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        steam
      ];
    };
}
