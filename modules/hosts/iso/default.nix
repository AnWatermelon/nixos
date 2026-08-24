{
  config,
  inputs,
  lib,
  self,
  ...
}:
{
  flake.nixosConfigurations.iso = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      (
        {
          modulesPath,
          pkgs,
          ...
        }:
        let
          installLayouts = pkgs.runCommand "max-install-layouts" { } ''
            mkdir -p "$out"
            cp ${./_disko-btrfs.nix} "$out/btrfs.nix"
            cp ${./_disko-ext4.nix} "$out/ext4.nix"
          '';
          maxInstall = pkgs.writeShellScriptBin "max-install" ''
            export MAX_LAYOUT_DIR="${installLayouts}"
            export FLAKE_REV="${self.rev or ""}"
            ${builtins.readFile ./max-install.sh}
          '';
        in
        {
          imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-base.nix") ];

          nixpkgs.hostPlatform = "x86_64-linux";
          boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
          boot.supportedFilesystems.zfs = lib.mkForce false;

          zramSwap.enable = true;
          zramSwap.memoryPercent = 100;
          systemd.services.enlarge-rwstore = {
            description = "Lift the cap on the RAM-backed writable Nix store";
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            script = ''
              mount -o remount,size=100% /nix/.rw-store
            '';
          };

          environment.systemPackages = with pkgs; [
            age
            btrfs-progs
            dosfstools
            gptfdisk
            inputs.disko.packages.${pkgs.system}.disko
            maxInstall
          ];

          isoImage = {
            edition = "Max";
            contents = [
              {
                source = self;
                target = "/etc/nixos/flake";
              }
            ];
          };

          services.getty.autologinUser = lib.mkForce "maxfh";
          users.users.maxfh.initialPassword = "nixos";
        }
      )

      { networking.hostName = "iso"; }

      config.flake.modules.nixos.networking
      config.flake.modules.nixos.locale
      config.flake.modules.nixos.users
      config.flake.modules.nixos.core

      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          users.maxfh.imports = [
            config.flake.modules.homeManager.base
          ];
        };
      }
    ];
  };

  perSystem = _: {
    packages.iso = config.flake.nixosConfigurations.iso.config.system.build.isoImage;
  };
}
