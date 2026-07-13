{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.darwin."lima" = {
    config,
    pkgs,
    ...
  }:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.apps.lima;
in {
  options.dariodots.apps.lima = with types; {
    enable = mkBoolOpt false "Whether or not to enable `lima`.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [lima];
  };
};
}
