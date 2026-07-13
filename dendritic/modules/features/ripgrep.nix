{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.homeManager."ripgrep" = {
    config,
    pkgs,
    ...
  }:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.ripgrep;
in {
  options.dariodots.cli-apps.ripgrep = with types; {
    enable = mkBoolOpt false "Whether or not to enable `ripgrep`.";
  };

  config = mkIf cfg.enable {
    programs.ripgrep = {
      enable = true;
    };
  };
};
}
