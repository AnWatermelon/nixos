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
          substituters = [ "https://attic.xuyh0120.win/lantian" ];
          trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
        };

        boot.kernelPackages = pkgs.cachyosKernels."linuxPackages-cachyos-${cfg.cachyos}";
      };
    };
}
