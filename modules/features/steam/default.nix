{
  flake.modules.homeManager.steam =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        steam
      ];
    };
}
