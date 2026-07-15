{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake.modules.homeManager.direnv =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

    };
}
