{
  flake.modules.nixos.kernel =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      cfg = config.my.kernel;
    in
    {
      imports = [ ./options.nix ];

      config = lib.mkIf (cfg.cachyos != null) {
        nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];

        nix.settings = {
          extra-substituters = [ "https://cache.lantian.pub/lantian" ];
          extra-trusted-public-keys = [ "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=" ];
        };

        boot.kernelPackages = pkgs.cachyosKernels."linuxPackages-cachyos-${cfg.cachyos}";
      };
    };
}
