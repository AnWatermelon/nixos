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
          installLayouts = pkgs.runCommand "install-host-layouts" { } ''
            mkdir -p "$out"
            cp ${./_disko-btrfs.nix} "$out/btrfs.nix"
            cp ${./_disko-ext4.nix} "$out/ext4.nix"
          '';
          installHost = pkgs.writeShellScriptBin "install-host" ''
            export MAX_LAYOUT_DIR="${installLayouts}"
            export FLAKE_REV="${self.rev or ""}"
            ${builtins.readFile ./install-host.sh}
          '';
          # Optionally pre-unlock the hosts' SSH host keys (which double as
          # their sops-nix age keys) at ISO build time, so install-host can
          # skip its interactive age passphrase prompt.
          #
          # The passphrase is never passed as an environment variable: point
          # MAX_ISO_PASSPHRASE_FILE at a file containing it (typically a
          # root-only file copied into user-readable space by the sudo gate
          # in scripts/build-iso.sh):
          #   nix run .#build-iso
          #   MAX_ISO_PASSPHRASE_FILE=/path/to/file nix build --impure .#iso
          # Pure builds see an empty string here and are left untouched.
          unlockedHostKeys =
            let
              hostsDir = "${self}/modules/hosts";
              hostNames = builtins.attrNames (builtins.readDir hostsDir);
              hostsWithKeys = builtins.filter (
                name: builtins.pathExists "${hostsDir}/${name}/ssh_host_ed25519_key.age"
              ) hostNames;
              phraseFile = builtins.getEnv "MAX_ISO_PASSPHRASE_FILE";
            in
            if phraseFile == "" || hostsWithKeys == [ ] then
              null
            else
              pkgs.runCommand "iso-unlocked-hostkeys"
                {
                  nativeBuildInputs = [
                    pkgs.age
                    pkgs.util-linux
                  ];
                  # Copy the phrase file into the store at eval time: the
                  # derivation env only ever contains the store path, not the
                  # passphrase itself.
                  phrase =
                    /.
                    + (
                      if lib.hasPrefix "/" phraseFile then
                        phraseFile
                      else
                        throw "MAX_ISO_PASSPHRASE_FILE must be an absolute path"
                    );
                }
                ''
                  mkdir -p "$out"
                  phrase="$(cat "$phrase")"
                  ${lib.concatMapStringsSep "\n" (host: ''
                    mkdir -p "$out/${host}"
                    echo "iso: unlocking ${host} SSH host key with build-time passphrase" >&2
                    # age refuses to read a passphrase from non-terminal stdin,
                    # so feed it through a pty with script(1).
                    if ! printf '%s\n' "$phrase" | script -qec \
                        "${pkgs.age}/bin/age -d -o $out/${host}/ssh_host_ed25519_key ${hostsDir}/${host}/ssh_host_ed25519_key.age" /dev/null; then
                      echo "iso: failed to unlock ${host} SSH host key (wrong passphrase?)" >&2
                      exit 1
                    fi
                  '') hostsWithKeys}
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
            inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
            installHost
          ];

          isoImage = {
            edition = "Max";
            contents = [
              {
                source = self;
                target = "/etc/nixos/flake";
              }
            ]
            ++ lib.optional (unlockedHostKeys != null) {
              source = unlockedHostKeys;
              target = "/unlocked-hostkeys";
            };
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

  perSystem = { pkgs, ... }: {
    packages = {
      iso = config.flake.nixosConfigurations.iso.config.system.build.isoImage;
      build-iso = pkgs.writeShellScriptBin "build-iso" (builtins.readFile ../../../scripts/build-iso.sh);
    };
  };
}
