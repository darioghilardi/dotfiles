{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.homeManager."htop" = {
    config,
    pkgs,
    ...
  }:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.htop;
in {
  options.dariodots.cli-apps.htop = with types; {
    enable = mkBoolOpt false "Whether or not to enable `htop`.";
  };

  config = mkIf cfg.enable {
    programs.htop = {
      enable = true;
      settings.show_program_path = true;
    };
  };
};
}
