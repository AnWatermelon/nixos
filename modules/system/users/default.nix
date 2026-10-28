{ config, ... }:
{
  flake.modules.nixos.users = _: {
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
    };
    nix.settings.trusted-users = [
      "root"
      "@wheel"
    ];
  };
}
