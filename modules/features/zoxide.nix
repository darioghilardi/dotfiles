{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake.modules.homeManager.zoxide =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    {
      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
      };

    };
}
