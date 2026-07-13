# bat — a substitute for cat. https://github.com/sharkdp/bat
# Phase-B aspect: contributes the home-manager slice via flake.modules.homeManager.
# Helpers come from the file's lexical closure (no lib.dariodots injection needed).
{inputs, ...}: let
  inherit (import ../../lib/dariodots {inherit (inputs.nixpkgs) lib;}) mkBoolOpt;
in {
  flake.modules.homeManager.bat = {
    config,
    lib,
    ...
  }:
    with lib; let
      cfg = config.dariodots.cli-apps.bat;
    in {
      options.dariodots.cli-apps.bat = with types; {
        enable = mkBoolOpt false "Whether or not to enable `bat`.";
      };

      config = mkIf cfg.enable {
        programs.bat = {
          enable = true;
          config = {
            style = "plain";
            theme = "Solarized (dark)";
          };
        };
      };
    };
}
