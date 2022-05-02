{ config, lib, pkgs, ... }:
{
  home.stateVersion = "22.05";

  imports = [
    ./kitty.nix
    ./kitty-extras.nix
  ];
}
