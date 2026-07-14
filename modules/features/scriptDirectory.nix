{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.modules.homeManager.scriptDirectory = {
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
