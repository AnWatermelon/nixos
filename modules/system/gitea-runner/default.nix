{
  flake.modules.nixos.gitea-runner =
    { config, lib, pkgs, ... }:
    {
      services.gitea-actions-runner = {
        package = pkgs.gitea-actions-runner;
        instances.cache = {
          enable = true;
          name = "cache";
          url = "https://gitea.hilton-tech.net";
          tokenFile = "/var/lib/gitea-runner/token";
          labels = [
            "native:host"
            "ubuntu-latest:host"
          ];
          hostPackages = with pkgs; [
            bash
            coreutils
            curl
            git
            gnutar
            gzip
            jq
            nix
          ];
        };
      };

      systemd.services."gitea-runner-cache".unitConfig.ConditionPathExists = "/var/lib/gitea-runner/token";

      systemd.tmpfiles.rules = [
        "d /var/lib/gitea-runner 0750 root root -"
      ];
    };
}
