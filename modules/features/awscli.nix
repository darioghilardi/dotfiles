{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake.modules.homeManager."awscli" =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    {
      programs.awscli = {
        enable = true;
      };

    };
}
