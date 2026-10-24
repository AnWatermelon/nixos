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

        boot.kernelPackages = pkgs.cachyosKernels."linuxPackages-cachyos-${cfg.cachyos}";
      };
    };
}
