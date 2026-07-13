{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.awscli;
in {
  options.dariodots.cli-apps.awscli = with types; {
    enable = mkBoolOpt false "Whether or not to enable `awscli`.";
  };

  config = mkIf cfg.enable {
    programs.awscli = {
      enable = true;
    };
  };
}
