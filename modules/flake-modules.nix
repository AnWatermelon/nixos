{ lib, inputs, ... }:
{
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  options.flake.modules = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
    default = { };
    description = "Deferred modules organized by class and feature";
  };
}
