{
  # Single source of truth for the shared helper scripts. Imported by every
  # window-manager feature that binds them (hyprland, niri).
  flake.modules.homeManager.scripts = {
    xdg.configFile."scripts/toggle_audio.sh" = {
      source = ./toggle_audio.sh;
      executable = true;
    };
  };
}
