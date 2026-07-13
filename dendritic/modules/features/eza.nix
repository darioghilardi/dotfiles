{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.homeManager."eza" = {
    config,
    pkgs,
    ...
  }:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.eza;
in {
  # Eza, substitute for `ls`.
  # https://github.com/eza-community/eza

  options.dariodots.cli-apps.eza = with types; {
    enable = mkBoolOpt false "Whether or not to enable `eza`.";
  };

  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
    };
  };
};
}
