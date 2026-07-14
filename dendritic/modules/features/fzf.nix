{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.modules.homeManager."fzf" = {
    config,
    pkgs,
    ...
  }:
    with lib; {
    programs.fzf = {
      enable = true;
    };
  
    };
}
