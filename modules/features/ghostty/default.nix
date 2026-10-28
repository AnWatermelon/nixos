_: {
  flake.modules.nixos.ghostty =
    { config, lib, ... }:
    {
      my.dotfiles.files = lib.mkIf (lib.getName config.my.terminal == "ghostty") {
        ".config/ghostty/config".source = ./config;
      };
    };
}
