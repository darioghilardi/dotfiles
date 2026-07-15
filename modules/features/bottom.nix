{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake.modules.homeManager.bottom =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    {
      programs.bottom = {
        enable = true;
      };

    };
}
