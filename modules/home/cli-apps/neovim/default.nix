{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.neovim;
in {
  options.dariodots.cli-apps.neovim = with types; {
    enable = mkBoolOpt false "Whether or not to enable `neovim`.";
  };

  config = {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
