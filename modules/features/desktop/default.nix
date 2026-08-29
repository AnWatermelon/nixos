{
  lib,
  inputs,
  ...
}:
{
  flake.modules.nixos.desktop =
    { pkgs, config, ... }:
    let
      cfg = config.my.desktop;
    in
    {
      imports = [
        ./options.nix
        inputs.self.modules.nixos.steam
        inputs.self.modules.nixos.greetd
      ];

      config = lib.mkMerge [
        {
          environment.systemPackages = [
            inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
            pkgs.lunar-client
            pkgs.heroic
          ];
        }
        {
          programs.dconf.enable = true;
        }
        (lib.mkIf (cfg.environment == "hyprland") {
          programs.hyprland = {
            enable = true;
            xwayland.enable = true;
          };
        })
        (lib.mkIf (cfg.environment == "gnome") {
          services = {
            displayManager.gdm.enable = true;
            desktopManager.gnome.enable = true;
          };
        })
      ];
    };
  flake.modules.homeManager.desktop =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      imports = [
        ./options.nix
        inputs.self.modules.homeManager.terminal
        inputs.self.modules.homeManager.discord
        inputs.self.modules.homeManager.zen-browser
        inputs.self.modules.homeManager.hyprland
        inputs.self.modules.homeManager.niri
        inputs.self.modules.homeManager.noctalia
      ];

      gtk = {
        enable = true;
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
      };

      home.packages = lib.optionals (cfg.environment == "hyprland") [ pkgs.hyprland ];

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adw-gtk3-dark";
        };
      };
    };
}
