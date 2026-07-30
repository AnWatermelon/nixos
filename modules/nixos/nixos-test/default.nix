{ config, inputs, ... }:
{
  flake.nixosConfigurations.nixos-test = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      ./_configuration.nix
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.maxfh = {
            imports = [
              config.flake.modules.homeManager.base
              config.flake.modules.homeManager.terminal
              config.flake.modules.homeManager.git
              config.flake.modules.homeManager.ssh
            ];
          };
        };
      }
    ];
  };
}
