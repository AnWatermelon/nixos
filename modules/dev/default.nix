{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      # `nix fmt` — nixfmt over the whole tree.
      formatter = pkgs.nixfmt-tree;

      # `nix flake check` — lint gates that catch unused bindings, dead code
      # and unformatted files.
      checks = {
        deadnix = pkgs.runCommandLocal "check-deadnix" { nativeBuildInputs = [ pkgs.deadnix ]; } ''
          deadnix --fail ${inputs.self}
          touch $out
        '';

        statix = pkgs.runCommandLocal "check-statix" { nativeBuildInputs = [ pkgs.statix ]; } ''
          statix check ${inputs.self}
          touch $out
        '';

        nixfmt =
          pkgs.runCommandLocal "check-nixfmt"
            {
              nativeBuildInputs = [
                pkgs.nixfmt
                pkgs.fd
              ];
            }
            ''
              fd --extension nix --type file . ${inputs.self} --exec-batch nixfmt --check
              touch $out
            '';
      };
    };
}
