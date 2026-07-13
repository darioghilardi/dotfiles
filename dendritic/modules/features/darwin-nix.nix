{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.darwin."nix" = {
    config,
    pkgs,
    ...
  }: {
  # DeterminateSystem installer manages the nix daemon.
  nix.enable = false;
};
}
