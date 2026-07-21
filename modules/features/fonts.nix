{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake.modules.homeManager.fonts =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    {
      fonts.fontconfig.enable = true;

      home.packages = with pkgs; [
        nerd-fonts.iosevka
      ];
    };
}
