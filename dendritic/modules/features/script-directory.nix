{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.modules.homeManager."script-directory" = {
    config,
    pkgs,
    ...
  }:
    with lib; {
    programs.script-directory = {
      enable = true;
    };
  
    };
}
