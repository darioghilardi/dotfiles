{
  lib,
  inputs,
  config,
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
}
