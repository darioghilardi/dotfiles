# Dendritic aspect registry: `flake.modules.<class>.<feature>`. Each feature
# file under ../features contributes a deferredModule to one or more classes
# (homeManager / darwin / nixos); host modules compose `config.flake.modules.*`
# into their darwinSystem / nixosSystem. flake-parts declares nixosModules etc.
# but not this generic grouping, so we declare it here.
{ lib, ... }: {
  options.flake.modules = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
    default = { };
    description = "Aspect modules grouped by class (homeManager/darwin/nixos).";
  };
}
