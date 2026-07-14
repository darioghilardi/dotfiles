{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.modules.homeManager."eza" = {
    config,
    pkgs,
    ...
  }:
    with lib; {
    programs.eza = {
      enable = true;
    };
  
    };
}
