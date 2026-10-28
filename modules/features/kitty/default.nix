_: {
  flake.modules.nixos.kitty =
    { config, lib, ... }:
    {
      my.dotfiles.files = lib.mkIf (lib.getName config.my.terminal == "kitty") {
        ".config/kitty/kitty.conf".source = ./kitty.conf;
      };
    };
}
