{
  nixpkgs.hostPlatform = "x86_64-linux";

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };
}
