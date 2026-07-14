{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.modules.homeManager."htop" = {
    config,
    pkgs,
    ...
  }:
    with lib; {
    programs.htop = {
      enable = true;
      settings.show_program_path = true;
    };
  
    };
}
