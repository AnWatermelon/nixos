{
  flake.modules.nixos.obs =
    {
      config,
      pkgs,
      ...
    }:
    let
      isNvidia = (config.my.hardware.gpu.vendor or null) == "nvidia";
    in
    {
      programs.obs-studio = {
        enable = true;
        enableVirtualCamera = true;
        package = if isNvidia then pkgs.obs-studio.override { cudaSupport = true; } else pkgs.obs-studio;
        plugins = with pkgs.obs-studio-plugins; [
          obs-vaapi
          obs-gstreamer
          obs-vkcapture
          obs-pipewire-audio-capture
          wlrobs
        ];
      };
    };
}
