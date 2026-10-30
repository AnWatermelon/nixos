{
  config,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.cache = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      inputs.disko.nixosModules.disko
      ./_disko.nix
      ./_hardware-configuration.nix
      ./_bootloader.nix

      ({ lib, ... }: {
        networking = {
          hostName = "cache";
          networkmanager.enable = true;
        };
        services.mullvad-vpn.enable = lib.mkForce false;
        hardware.bluetooth.enable = lib.mkForce false;
      })

      {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = true;
            PermitRootLogin = "yes";
          };
        };
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKw5A/npS9wxClux6eU5Zy8w9Ahblm98g4HY3QTLtuZd maxfh@fw16"
        ];
        users.users.maxfh.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKw5A/npS9wxClux6eU5Zy8w9Ahblm98g4HY3QTLtuZd maxfh@fw16"
        ];
      }

      config.flake.modules.nixos.boot
      config.flake.modules.nixos.networking
      config.flake.modules.nixos.locale
      config.flake.modules.nixos.users
      config.flake.modules.nixos.core
      config.flake.modules.nixos.hardware
      config.flake.modules.nixos.qemu-guest
      config.flake.modules.nixos.harmonia
      config.flake.modules.nixos.gitea-runner
    ];
  };
}
