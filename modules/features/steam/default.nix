{
  flake.modules.nixos.steam =
    { pkgs, inputs, ... }:
    {
      nixpkgs.overlays = [ inputs.millennium.overlays.default ];
      programs.steam = {
        enable = true;
        package = pkgs.millennium-steam;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };
      environment.systemPackages = [
        pkgs.mangohud
      ];
    };
}
