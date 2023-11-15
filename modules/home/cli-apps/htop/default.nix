{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.htop;
in {
  options.dariodots.cli-apps.htop = with types; {
    enable = mkBoolOpt false "Whether or not to enable `htop`.";
  };

  config = {
    programs.htop = {
      enable = true;
      settings.show_program_path = true;
    };
  };
}
