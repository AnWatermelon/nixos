{
  # Single source of truth for the shared helper scripts. Imported by every
  # window-manager feature that binds them (hyprland, niri).
  flake.modules.nixos.scripts =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "toggle_audio" (builtins.readFile ./toggle_audio.sh))
      ];
    };

  flake.modules.homeManager.scripts = _: {
    xdg.configFile."scripts/toggle_audio.sh" = {
      source = ./toggle_audio.sh;
      executable = true;
    };
  };
}
