{ config, inputs, ... }:
{
  # Provides `flake.modules.<class>.<name>`: deferred modules keyed by class,
  # tagged with `_class`/`_file` so a homeManager module imported into a NixOS
  # config is a type error rather than a confusing evaluation failure.
  # They are also published as the flake's `modules` output.
  imports = [ inputs.flake-parts.flakeModules.modules ];

  systems = [ "x86_64-linux" ];

  # Also publish under the conventional output names so other flakes can
  # consume these without knowing about the `modules` convention.
  flake.nixosModules = config.flake.modules.nixos;
  flake.homeModules = config.flake.modules.homeManager;
}
