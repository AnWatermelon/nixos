{ lib, ... }:
{
  options.my.kernel.cachyos = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "bore-lto";
    description = ''
      CachyOS kernel variant to boot, from xddxdd/nix-cachyos-kernel. Default
      keeps the plain nixpkgs kernel from `boot`.

      Resolves to `pkgs.cachyosKernels.linuxPackages-cachyos-<variant>`, e.g.
      "latest", "lts", "bore", "bore-lto", "lts-lto", "hardened". See
      https://github.com/xddxdd/nix-cachyos-kernel#which-kernel-versions-are-provided
      for the full variant list.
    '';
  };
}
