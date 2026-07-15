{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake.modules.homeManager.gh =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    {
      programs.gh.enable = true;
      programs.gh.settings = {
        git_protocol = "https";
        prompt = "enabled";
      };

    };
}
