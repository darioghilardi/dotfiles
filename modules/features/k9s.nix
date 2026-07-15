{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake.modules.homeManager."k9s" =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    {
      programs.k9s = {
        enable = true;
      };

    };
}
