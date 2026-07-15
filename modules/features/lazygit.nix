{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake.modules.homeManager."lazygit" =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    {
      programs.lazygit = {
        enable = true;
      };

    };
}
