{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.homeManager."lazygit" = {
    config,
    pkgs,
    ...
  }:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.lazygit;
in {
  options.dariodots.cli-apps.lazygit = with types; {
    enable = mkBoolOpt false "Whether or not to enable `lazygit`.";
  };

  config = mkIf cfg.enable {
    programs.lazygit = {
      enable = true;
    };
  };
};
}
