{
  flake.modules.nixos.steam =
    { pkgs, inputs, ... }:
    let
      millennium = inputs.millennium.packages.${pkgs.stdenv.hostPlatform.system}.millennium;
      millenniumSteam = pkgs.steam.override {
        extraLibraries = pkgs: [
          millennium
          pkgs.pkgsi686Linux.openssl
          pkgs.openssl
        ];
        extraEnv = {
          MILLENNIUM_RUNTIME_PATH = "${millennium}/lib/libmillennium_x86.so";
        };
        extraProfile = ''
          ln -sf ${millennium}/lib/libmillennium_bootstrap_x86.so "$HOME/.local/share/Steam/ubuntu12_32/libXtst.so.6"
          ln -sf ${millennium}/lib/libmillennium_bootstrap_hhx64.so "$HOME/.local/share/Steam/ubuntu12_64/libXtst.so.6"
        '';
      };
    in
    {
      programs = {
        steam = {
          enable = true;
          package = millenniumSteam;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
        };
        gamescope.enable = true;
      };
      environment.systemPackages = [
        pkgs.mangohud
      ];
    };
}
