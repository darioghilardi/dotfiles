{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.homeManager."bottom" = {
    config,
    pkgs,
    ...
  }:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.bottom;
in {
  # Bottom, substitute for `top`.
  # https://github.com/ClementTsang/bottom

  options.dariodots.cli-apps.bottom = with types; {
    enable = mkBoolOpt false "Whether or not to enable `bottom`.";
  };

  config = mkIf cfg.enable {
    programs.bottom = {
      enable = true;
    };
  };
};
}
