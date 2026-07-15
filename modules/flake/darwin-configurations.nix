# flake-parts core declares a mergeable option for `flake.nixosConfigurations`
# but not for `flake.darwinConfigurations` (it's a third-party output). Without
# a declared option it's a freeform attr that expects a single definition, so
# two host modules each setting it would collide. Declare it as merge-by-key so
# every host module can contribute its own entry.
{ lib, ... }: {
  options.flake.darwinConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
    description = "nix-darwin configurations, one entry per host module.";
  };
}
