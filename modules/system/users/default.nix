{ config, ... }:
{
  flake.modules.nixos.users =
    { pkgs, ... }:
    {
      imports = [ config.flake.modules.nixos.dotfiles ];

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
