{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.bat;
in {
  # Bat, a substitute for cat.
  # https://github.com/sharkdp/bat

  options.dariodots.cli-apps.bat = with types; {
    enable = mkBoolOpt false "Whether or not to enable `bat`.";
  };

  config = {
    programs.bat = {
      enable = true;
      config = {
        style = "plain";
        theme = "Solarized (dark)";
      };
    };
  };
}
