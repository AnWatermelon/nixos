{ config, inputs, ... }:
{
  flake.homeConfigurations.maxfh = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = { inherit inputs; };
    modules = [
      config.flake.modules.homeManager.base
      config.flake.modules.homeManager.terminal
      config.flake.modules.homeManager.hyprland
      config.flake.modules.homeManager.kitty
      config.flake.modules.homeManager.zsh

      # Use the system kitty on Arch — the nixpkgs-built kitty segfaults
      # during Wayland window creation (glfw-wayland.so ABI mismatch).
      (
        { pkgs, ... }:
        let
          kitty-system = pkgs.writeShellScriptBin "kitty" ''
            exec /usr/bin/kitty "$@"
          '';
        in
        {
          my.terminal = kitty-system;
          programs.kitty.package = kitty-system;
        }
      )
    ];
  };
}
