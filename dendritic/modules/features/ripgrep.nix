{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.modules.homeManager."ripgrep" = {
    config,
    pkgs,
    ...
  }:
    with lib; {
    programs.ripgrep = {
      enable = true;
    };
  
    };
}
