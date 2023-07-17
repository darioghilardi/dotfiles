{ config, lib, pkgs, ... }: {
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  home.username = "dario";
  home.homeDirectory = "/Users/dario";
  home.sessionVariables = { EDITOR = "nvim"; };

  # Some weird bug
  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;

  imports = [
    ./kitty.nix
    ./kitty-extras.nix
    ./packages.nix
    ./git.nix
    ./fish.nix
    ./starship.nix
  ];
}
