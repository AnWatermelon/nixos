{
  # Helper scripts on PATH, bound by the window-manager configs (hyprland, niri).
  flake.modules.nixos.scripts =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "toggle_audio" (builtins.readFile ./toggle_audio.sh))
      ];
    };
}
