{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.homeManager."jq" = {
    config,
    pkgs,
    ...
  }:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.jq;
in {
  options.dariodots.cli-apps.jq = with types; {
    enable = mkBoolOpt false "Whether or not to enable `jq`.";
  };

  config = mkIf cfg.enable {
    programs.jq = {
      enable = true;
    };
  };
};
}
