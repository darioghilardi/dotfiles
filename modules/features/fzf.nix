{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.modules.homeManager.fzf = {
    config,
    pkgs,
    ...
  }:
    with lib; {
      programs.fzf = {
        enable = true;
        # Fish keybindings come from the PatrickF1/fzf.fish plugin (see fish.nix),
        # so disable home-manager's own integration to avoid duplicate Ctrl-R /
        # Ctrl-T / Alt-C bindings.
        enableFishIntegration = false;
      };
    };
}
