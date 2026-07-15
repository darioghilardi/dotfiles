{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake.modules.homeManager."bat" =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    {
      programs.bat = {
        enable = true;
        config = {
          style = "plain";
          theme = "Solarized (dark)";
        };
      };

    };
}
