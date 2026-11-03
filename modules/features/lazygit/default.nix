{ inputs, ... }:
{
  flake.modules.nixos.lazygit =
    { pkgs, ... }:
    let
      settings = {
        promptToReturnFromSubprocess = false;
        git.diffRenderers = [
          { command = "${pkgs.delta}/bin/delta --paging=never --line-numbers --file-style omit --hunk-header-style omit --syntax-theme ansi --minus-style 'syntax' --plus-style 'syntax' --minus-emph-style 'reverse red' --plus-emph-style 'reverse green' --line-numbers-minus-style red --line-numbers-plus-style green"; }
        ];
      };
      configFile = (pkgs.formats.yaml { }).generate "lazygit-config.yml" settings;
    in
    {
      imports = [
        (inputs.nix-wrapper-modules.lib.getInstallModule {
          name = "lazygit";
          value =
            { wlib, pkgs, ... }:
            {
              imports = [ wlib.modules.default ];
              package = pkgs.lazygit;
            };
        })
      ];

      wrappers.lazygit = {
        enable = true;
        env.LG_CONFIG_FILE = {
          data = "${configFile},$HOME/.config/lazygit/config.yml";
          esc-fn = s: ''"${s}"'';
        };
      };
    };
}
