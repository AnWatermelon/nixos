{
  flake.modules.nixos.fprint = {
    services.fprintd.enable = true;
    security.pam.services.sudo.fprintAuth = false;
    security.pam.services.su.fprintAuth = false;
  };
}
