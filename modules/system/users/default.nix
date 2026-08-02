{
  flake.modules.nixos.users =
    { pkgs, ... }:
    {
      users.users."maxfh" = {
        isNormalUser = true;
        description = "Max Hilton";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.zsh;
      };
    };
}
