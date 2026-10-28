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
        inputs.self.modules.nixos.vivaldi
        inputs.self.modules.nixos.zen-browser
        inputs.self.modules.nixos.obs
        inputs.self.modules.nixos.greetd
        inputs.self.modules.nixos.xdg
        inputs.self.modules.nixos.flatpak
        inputs.self.modules.nixos.scripts
        inputs.self.modules.nixos.kitty
        inputs.self.modules.nixos.ghostty
        inputs.self.modules.nixos.hyprland
        inputs.self.modules.nixos.noctalia
        inputs.self.modules.nixos.mimeapps
        inputs.self.modules.nixos.discord
        inputs.self.modules.nixos.nemo
      ];

      config = lib.mkMerge [
        {
          environment.systemPackages = with pkgs; [
            config.my.terminal
            lunar-client
            heroic
            gale
            prusa-slicer
            antigravity-ide
            spotify-player
            electrum
            libreoffice
            obs-studio
            godot
          ];
        }
        {
          environment = {
            systemPackages = [ pkgs.adw-gtk3 ];
            etc = {
              "xdg/gtk-3.0/settings.ini".text = ''
                [Settings]
                gtk-theme-name=adw-gtk3-dark
              '';
              "xdg/gtk-4.0/settings.ini".text = ''
                [Settings]
              '';
              "gtk-2.0/gtkrc".text = ''
                gtk-theme-name = "adw-gtk3-dark"
              '';
            };
            sessionVariables.GTK2_RC_FILES = "/etc/gtk-2.0/gtkrc";
          };
          programs.dconf = {
            enable = true;
            profiles.user.databases = [
              {
                settings."org/gnome/desktop/interface" = {
                  color-scheme = "prefer-dark";
                  gtk-theme = "adw-gtk3-dark";
                };
              }
            ];
          };
          services = {
            gvfs.enable = true;
            udisks2.enable = true;
          };
        }
        (lib.mkIf (cfg.environment == "hyprland") {
          environment.systemPackages = [
            inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
          programs.hyprland = {
            enable = true;
            xwayland.enable = true;
            withUWSM = true;
          };
          services.greetd.enable = lib.mkForce true;
          xdg.portal.extraPortals = [
            pkgs.xdg-desktop-portal-hyprland
          ];
        })
        (lib.mkIf (cfg.environment == "gnome") {
          services = {
            displayManager.gdm.enable = true;
            desktopManager.gnome.enable = true;
          };
          xdg.portal.extraPortals = [
            pkgs.xdg-desktop-portal-gtk
          ];
        })
      ];
    };
  flake.modules.homeManager.desktop =
    { osConfig, ... }:
    {
      # Transitional: browser modules now live on the NixOS side.
      my.desktop.browserCommand = osConfig.my.desktop.browserCommand;

      # Transitional: niri still reads the terminal from HM.
      my.terminal = osConfig.my.terminal;

      imports = [
        ./options.nix
        ../hardware/options.nix # transitional: hosts still forward my.hardware
        {
          options.my.terminal = lib.mkOption {
            type = lib.types.package;
            description = "Default terminal";
          };
        }
        inputs.self.modules.homeManager.niri
      ];
    };
}
