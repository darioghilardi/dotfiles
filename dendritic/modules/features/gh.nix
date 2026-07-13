{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.homeManager."gh" = {
    config,
    pkgs,
    ...
  }:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.gh;
in {
  options.dariodots.cli-apps.gh = with types; {
    enable = mkBoolOpt false "Whether or not to enable `gh`, the Github CLI.";
  };

  config = mkIf cfg.enable {
    programs.gh.enable = true;
    programs.gh.settings = {
      git_protocol = "https";
      prompt = "enabled";
    };
  };
};
}
