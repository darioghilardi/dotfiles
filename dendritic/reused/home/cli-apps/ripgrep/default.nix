{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.ripgrep;
in {
  options.dariodots.cli-apps.ripgrep = with types; {
    enable = mkBoolOpt false "Whether or not to enable `ripgrep`.";
  };

  config = mkIf cfg.enable {
    programs.ripgrep = {
      enable = true;
    };
  };
}
