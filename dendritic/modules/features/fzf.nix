{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.homeManager."fzf" = {
    config,
    pkgs,
    ...
  }:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.fzf;
in {
  options.dariodots.cli-apps.fzf = with types; {
    enable = mkBoolOpt false "Whether or not to enable `fzf`.";
  };

  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
    };
  };
};
}
