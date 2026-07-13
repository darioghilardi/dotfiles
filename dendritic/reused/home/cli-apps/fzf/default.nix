{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.fzf;
in {
  options.dariodots.cli-apps.fzf = with types; {
    enable = mkBoolOpt false "Whether or not to enable `fzf`.";
  };

  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
    };
  };
}
