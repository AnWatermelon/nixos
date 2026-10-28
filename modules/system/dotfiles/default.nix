{ inputs, ... }:
{
  # Links files into the user's home without home-manager.
  #
  # Every generation builds two trees: a store tree (copies as built) and a
  # live tree (files sourced from this repo point at the checkout instead).
  # Home paths link through ~/.local/state/dotfiles/current, which activation
  # always resets to the store tree, so rollbacks restore configs exactly.
  # `dotfiles-live on` flips it to the live tree for rebuild-free editing.
  flake.modules.nixos.dotfiles =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.dotfiles;
      selfPrefix = "${inputs.self}/";

      files = lib.filter (f: f.enable) (lib.attrValues cfg.files);

      repoPath =
        f:
        let
          source = toString f.source;
        in
        if f.live && lib.hasPrefix selfPrefix source then lib.removePrefix selfPrefix source else null;

      mkTree =
        name: live:
        pkgs.linkFarm name (
          map (f: {
            name = f.target;
            path = if live && repoPath f != null then "${cfg.flakePath}/${repoPath f}" else f.source;
          }) files
        );

      storeTree = mkTree "dotfiles-store" false;
      liveTree = mkTree "dotfiles-live" true;
      manifest = pkgs.writeText "dotfiles-manifest" (lib.concatMapStrings (f: f.target + "\n") files);

      activate = pkgs.writeShellApplication {
        name = "dotfiles-activate";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.findutils
          pkgs.gnugrep
        ];
        text = ''
          state="''${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
          mkdir -p "$state"
          ln -sfn ${storeTree} "$state/current.new"
          mv -Tf "$state/current.new" "$state/current"

          # Links left behind by home-manager would shadow system-wide config.
          find "$HOME" -maxdepth 1 -type l -lname '/nix/store/*-home-manager-files/*' -delete
          for dir in "$HOME/.config" "$HOME/.local" "$HOME/.ssh"; do
            if [ -d "$dir" ]; then
              find "$dir" -xdev -type l -lname '/nix/store/*-home-manager-files/*' -delete
            fi
          done

          while IFS= read -r target; do
            dest="$HOME/$target"
            link="$state/current/$target"
            if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$link" ]; then
              continue
            fi
            if [ -L "$dest" ] && [[ "$(readlink "$dest")" == /nix/store/* ]]; then
              rm "$dest"
            elif [ -e "$dest" ] || [ -L "$dest" ]; then
              backup="$dest.dotfiles-bak"
              if [ -e "$backup" ] || [ -L "$backup" ]; then
                backup="$backup.$(date +%s)"
              fi
              echo "dotfiles: moving existing $dest to $backup" >&2
              mv "$dest" "$backup"
            fi
            mkdir -p "$(dirname "$dest")"
            ln -s "$link" "$dest"
          done < ${manifest}

          # Drop links for files no longer managed.
          if [ -f "$state/manifest" ]; then
            while IFS= read -r target; do
              if grep -qxF -- "$target" ${manifest}; then
                continue
              fi
              dest="$HOME/$target"
              if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$state/current/$target" ]; then
                rm "$dest"
              fi
            done < "$state/manifest"
          fi
          install -m 644 ${manifest} "$state/manifest"
        '';
      };

      live = pkgs.writeShellApplication {
        name = "dotfiles-live";
        runtimeInputs = [ pkgs.coreutils ];
        text = ''
          state="''${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
          point() {
            ln -sfn "$1" "$state/current.new"
            mv -Tf "$state/current.new" "$state/current"
          }
          case "''${1:-status}" in
            on)
              if [ ! -d ${lib.escapeShellArg cfg.flakePath} ]; then
                echo "dotfiles-live: checkout not found at ${cfg.flakePath}" >&2
                exit 1
              fi
              point ${liveTree}
              echo "live: repo-sourced configs now read from ${cfg.flakePath}"
              ;;
            off)
              point ${storeTree}
              echo "store: configs restored to this generation's copies"
              ;;
            status)
              if [ "$(readlink "$state/current")" = ${liveTree} ]; then
                echo live
              else
                echo store
              fi
              ;;
            *)
              echo "usage: dotfiles-live [on|off|status]" >&2
              exit 2
              ;;
          esac
        '';
      };
    in
    {
      options.my.dotfiles = {
        user = lib.mkOption {
          type = lib.types.str;
          default = "maxfh";
          description = "User whose home the files are linked into";
        };
        flakePath = lib.mkOption {
          type = lib.types.str;
          default = "/home/maxfh/Projects/nixos";
          description = "Location of this repo's checkout, used by live mode";
        };
        live = lib.mkEnableOption "the dotfiles-live command, which points repo-sourced files at the checkout";
        files = lib.mkOption {
          default = { };
          description = "Files to link, keyed by path relative to the home directory";
          type = lib.types.attrsOf (
            lib.types.submodule (
              { name, config, ... }:
              {
                options = {
                  enable = lib.mkEnableOption "this file" // {
                    default = true;
                  };
                  target = lib.mkOption {
                    type = lib.types.str;
                    default = name;
                    description = "Path relative to the home directory";
                  };
                  source = lib.mkOption {
                    type = lib.types.path;
                    description = "File or directory to link";
                  };
                  text = lib.mkOption {
                    type = lib.types.nullOr lib.types.lines;
                    default = null;
                    description = "Contents of the file, instead of source";
                  };
                  live = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                    description = "Whether live mode may redirect this file to the checkout (only files sourced from this repo can be)";
                  };
                };
                config.source = lib.mkIf (config.text != null) (
                  lib.mkDefault (pkgs.writeText (lib.strings.sanitizeDerivationName (baseNameOf name)) config.text)
                );
              }
            )
          );
        };
      };

      config = {
        system = {
          userActivationScripts.dotfiles = ''
            if [ "$(id -un)" = ${lib.escapeShellArg cfg.user} ]; then
              ${lib.getExe activate}
            fi
          '';
          build.dotfiles = storeTree;
          build.dotfilesLive = liveTree;
        };
        environment.systemPackages = lib.mkIf cfg.live [ live ];
      };
    };
}
