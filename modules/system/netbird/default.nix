{
  flake.modules.nixos.netbird = { config, inputs, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      defaultSopsFile = ./secrets/netbird-setup-key.yaml;
      secrets."netbird-setup-key" = {
        restartUnits = [ "netbird-wt0-login.service" ];
      };
    };

    services.netbird.clients.wt0 = {
      port = 443;

      login = {
        enable = true;
        setupKeyFile = config.sops.secrets."netbird-setup-key".path;
        systemdDependencies = [ "sops-install-secrets.service" ];
      };

      ui.enable = true;

      openFirewall = true;
      openInternalFirewall = true;

      environment = {
        NB_MANAGEMENT_URL = "https://netbird.hilton-tech.net";
        NB_ADMIN_URL = "https://netbird.hilton-tech.net";
      };
    };
  };
}
