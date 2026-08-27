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
          "input"
          "video"
        ];
        shell = pkgs.zsh;
      };
      nix.settings.trusted-users = [
        "root"
        "@wheel"
      ];
    };
}
