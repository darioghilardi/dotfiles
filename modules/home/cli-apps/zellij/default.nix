{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.zellij;
in {
  options.dariodots.cli-apps.zellij = with types; {
    enable = mkBoolOpt false "Whether or not to enable `zellij`.";
  };

  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        theme = "solarized-dark";
      };
    };
  };
}
