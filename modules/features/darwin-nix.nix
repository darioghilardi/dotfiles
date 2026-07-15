{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake.modules.darwin.nix =
    {
      config,
      pkgs,
      ...
    }:
    {
      # DeterminateSystem installer manages the nix daemon.
      nix.enable = false;
    };
}
