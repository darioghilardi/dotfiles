{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.script-directory;
in {
  # script-directory
  # https://github.com/ianthehenry/sd

  options.dariodots.cli-apps.script-directory = with types; {
    enable = mkBoolOpt false "Whether or not to enable `script-directory`.";
  };

  config = mkIf cfg.enable {
    programs.script-directory = {
      enable = true;
    };
  };
}
