{
  lib,
  pkgs,
  inputs,
  config,
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
}
