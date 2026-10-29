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
          config,
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
            disko
            installHost
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

          # Root only: a separate user with passwordless sudo protects
          # nothing, and install-host needs root anyway. No SSH keys are
          # provisioned for the ISO, so sshd would only offer password
          # logins.
          users.users.maxfh.enable = false;
          users.users.nixos.enable = false;
          users.users.root.shell = config.users.users.maxfh.shell;
          services.openssh.enable = lib.mkForce false;
          services.getty.helpLine = lib.mkForce ''
            Install with `install-host --disk <device> <host>`; see `install-host --help`.
            To set up a wireless connection, run `nmtui`.
          '';

          # kitty in cage on tty1, autologin gettys on the other VTs.
          services.getty.autologinUser = lib.mkForce "root";
          my = {
            dotfiles.user = "root";
            cage = {
              enable = true;
              autoLogin = true;
              user = "root";
            };
            terminal = pkgs.kitty;
            neovim.lean = true;
          };

          # Keep the image small: none of these serve an installer.
          services.mullvad-vpn.enable = lib.mkForce false;
          services.speechd.enable = lib.mkForce false;
          programs.appimage.enable = lib.mkForce false;
          # kitty has the Nerd Font symbols built in.
          fonts.enableDefaultPackages = lib.mkForce false;
          fonts.packages = [ pkgs.jetbrains-mono ];
        }
      )

      { networking.hostName = "iso"; }

      config.flake.modules.nixos.networking
      config.flake.modules.nixos.locale
      config.flake.modules.nixos.users
      config.flake.modules.nixos.core
      config.flake.modules.nixos.cage
      config.flake.modules.nixos.terminal
      config.flake.modules.nixos.kitty
      config.flake.modules.nixos.zsh
      config.flake.modules.nixos.tmux
      config.flake.modules.nixos.git
      config.flake.modules.nixos.neovim
    ];
  };

  perSystem = { pkgs, ... }: {
    packages = {
      iso = config.flake.nixosConfigurations.iso.config.system.build.isoImage;
      build-iso = pkgs.writeShellScriptBin "build-iso" ''
        export PATH="${
          lib.makeBinPath [
            pkgs.age
            pkgs.util-linux
            pkgs.xorriso
          ]
        }:$PATH"
        ${builtins.readFile ../../../scripts/build-iso.sh}
      '';
    };
  };
}
