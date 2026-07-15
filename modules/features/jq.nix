{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake.modules.homeManager.jq =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    {
      programs.jq = {
        enable = true;
      };

    };
}
