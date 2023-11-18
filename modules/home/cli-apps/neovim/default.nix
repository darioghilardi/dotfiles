{
  lib,
  inputs,
  config,
  pkgs,
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
    home.packages = [pkgs.neovim];

    xdg.configFile.nvim = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/modules/home/cli-apps/neovim/nvim";
      recursive = true;
    };
  };
}
