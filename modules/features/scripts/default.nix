{ config, lib, ... }:
let
  toggleAudioScript = builtins.readFile ./toggle_audio.sh;
in
{
  config.flake.modules.homeManager.scripts = { ... }: {
    home.file.".config/scripts/toggle_audio.sh" = {
      text = toggleAudioScript;
      executable = true;
    };
  };
}
