{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.tmux;
in {
  options.dariodots.cli-apps.tmux = with types; {
    enable = mkBoolOpt false "Whether or not to enable `tmux`.";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      keyMode = "vi";
      prefix = "C-b";
      escapeTime = 0;
      extraConfig = "set -g status-interval 0";
      tmuxinator.enable = true;
    };
  };
}
