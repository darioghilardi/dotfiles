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
      # This avoid zellij to autostarts on every new terminal.
      enableFishIntegration = false;
      settings = {
        theme = "solarized-dark";
        pane_frames = false;
      };
    };

    xdg.configFile."zellij/layouts" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/modules/home/cli-apps/zellij/layouts";
      recursive = true;
    };
  };
}
