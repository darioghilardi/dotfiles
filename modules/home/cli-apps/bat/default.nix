{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.tools.bat;
in {
  # Bat, a substitute for cat.
  # https://github.com/sharkdp/bat

  options.dariodots.cli-apps.bat = with types; {
    enable = mkBoolOpt false "Whether or not to enable `bat`, the Github CLI.";
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
