_: {
  # Takes over /etc/xdg/mimeapps.list from the NixOS xdg.mime module so that
  # defaults can also come from the .desktop files of packages, as home-manager's
  # xdg.mimeApps.defaultApplicationPackages did. Explicit xdg.mime entries win.
  flake.modules.nixos.mimeapps =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.xdg.mime;

      sections = {
        "Added Associations" = cfg.addedAssociations;
        "Default Applications" = cfg.defaultApplications;
        "Removed Associations" = cfg.removedAssociations;
      };

      generateSection =
        title: attrs:
        let
          isGlob = k: lib.hasSuffix "*" k;
          items = lib.mapAttrsToList (
            k: v:
            "generateMimeItem ${
              lib.escapeShellArgs [
                k
                v
              ]
            }"
          );
        in
        ''
          declare -A entries=()
          ${lib.concatStringsSep "\n" (
            # globs first so exact keys override them
            items (lib.filterAttrs (k: _: isGlob k) attrs) ++ items (lib.filterAttrs (k: _: !(isGlob k)) attrs)
          )}
          if [[ -s "$out" ]]; then printf '\n' >> "$out"; fi
          printf '%s\n' ${lib.escapeShellArg "[${title}]"} >> "$out"
          for mime in "''${!entries[@]}"; do
            printf '%s=%s\n' "$mime" "''${entries[$mime]}"
          done | sort >> "$out"
        '';

      baseFile = pkgs.runCommand "mimeapps-base.list" { } ''
        generateMimeItem() {
          local mime="$1" app="$2" type
          if [[ $mime == *\* ]]; then
            while IFS= read -r type; do
              if [[ -n $type && $type == "''${mime%\*}"* ]]; then
                entries["$type"]="$app"
              fi
            done < ${pkgs.shared-mime-info}/share/mime/types
          else
            entries["$mime"]="$app"
          fi
        }
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList generateSection sections)}
      '';

      mergedFile =
        pkgs.runCommand "mimeapps.list" { ps = config.my.desktop.defaultApplicationPackages; }
          ''
            export PATH=$PATH:${pkgs.crudini}/bin

            mergeEntry() {
              local mime="$1" name="$2" existing
              existing="$(crudini --get $out 'Default Applications' "$mime" 2>/dev/null || true)"
              crudini --ini-options=nospace --inplace --set $out 'Default Applications' "$mime" "$existing''${existing:+;}$name"
            }

            install -m644 ${baseFile} $out

            for p in $ps; do
              for path in "$p"/share/applications/*.desktop; do
                name="''${path##*/}"
                mimes=$(crudini --get "$path" 'Desktop Entry' MimeType 2>/dev/null || true)
                for mime in ''${mimes//;/ }; do
                  mergeEntry "$mime" "$name"
                done
              done
            done
          '';
    in
    {
      # The NixOS xdg.mime module writes this file too; ours replaces it.
      environment.etc."xdg/mimeapps.list".source = lib.mkForce mergedFile;
    };
}
