{
  lib,
  pkgs,
  inputs,
  system,
  target,
  format,
  virtual,
  systems,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.apps.opencode;
in {
  options.dariodots.apps.opencode = with types; {
    enable = mkBoolOpt false "Whether or not to enable `opencode`.";
  };

  config = mkIf cfg.enable {
    programs.opencode.enable = true;
  };
}
