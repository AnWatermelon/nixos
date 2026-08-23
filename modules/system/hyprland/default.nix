{
  flake.modules.nixos.hyprland =
    {
      config,
      lib,
      ...
    }:
    {
      imports = [ ../../features/desktop/options.nix ];

      config.programs.hyprland = lib.mkIf (config.my.desktop.environment == "hyprland") {
        enable = true;
        xwayland.enable = true;
      };
    };
}
