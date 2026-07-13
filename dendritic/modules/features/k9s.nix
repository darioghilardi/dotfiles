{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.homeManager."k9s" = {
    config,
    pkgs,
    ...
  }:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.k9s;
in {
  options.dariodots.cli-apps.k9s = with types; {
    enable = mkBoolOpt false "Whether or not to enable `k9s`.";
  };

  config = mkIf cfg.enable {
    programs.k9s = {
      enable = true;
    };
  };
};
}
