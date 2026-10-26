{
  flake.modules.nixos.harmonia = _: {
    services.harmonia.cache = {
      enable = true;
      signKeyPaths = [ "/var/lib/harmonia/cache-priv.pem" ];
      settings = {
        bind = "0.0.0.0:5000";
        priority = 30;
      };
    };

    networking.firewall.allowedTCPPorts = [ 5000 ];

    nix.settings = {
      trusted-users = [
        "root"
        "maxfh"
        "@wheel"
      ];
      keep-outputs = true;
      keep-derivations = true;
    };
  };
}
