{
  lib,
  inputs,
  config,
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
}
