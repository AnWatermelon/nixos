{ inputs, ... }:
{
  flake.modules.nixos.niri =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      user = config.my.dotfiles.user;
    in
    {
      options.my.desktop.niri.enable = lib.mkEnableOption "the niri desktop";

      config = lib.mkIf config.my.desktop.niri.enable {
        programs.niri = {
          enable = true;
          package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
        };

        # Host-dependent binds live in a generated file so config.kdl stays
        # a plain, live-editable repo file.
        my.dotfiles.files = {
          ".config/niri/config.kdl".source = ./config.kdl;
          ".config/niri/nix.kdl".text = ''
            binds {
                Mod+T hotkey-overlay-title=${builtins.toJSON "Open a Terminal: ${config.my.terminal.pname}"} { spawn ${builtins.toJSON (lib.getExe config.my.terminal)}; }
                Mod+B { spawn ${builtins.toJSON config.my.desktop.browserCommand}; }
            }
          '';
        };

        # noctalia rewrites its theme block in this file, so it is seeded once
        # as a real file instead of being linked from the store.
        system.userActivationScripts.niri-noctalia-seed = ''
          if [ "$(id -un)" = ${lib.escapeShellArg user} ] && [ ! -e "$HOME/.config/niri/noctalia.kdl" ]; then
            mkdir -p "$HOME/.config/niri"
            install -m 644 ${./noctalia.kdl.seed} "$HOME/.config/niri/noctalia.kdl"
          fi
        '';
      };
    };
}
