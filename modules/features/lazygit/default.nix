{ inputs, ... }:
{
  flake.modules.nixos.lazygit =
    { pkgs, ... }:
    let
      settings = {
        promptToReturnFromSubprocess = false;
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
