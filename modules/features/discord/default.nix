{
  flake.modules.nixos.discord =
    { pkgs, ... }:
    {
      users.users.maxfh.packages = with pkgs; [
        discord
        betterdiscordctl
      ];
    };
}
