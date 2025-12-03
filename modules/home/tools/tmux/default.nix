{
  lib,
  inputs,
  config,
  system,
  pkgs,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.tools.tmux;
  user = config.dariodots.user;
in {
  options.dariodots.tools.tmux = with types; {
    enable = mkBoolOpt false "Whether or not to enable git.";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      package = inputs.nixpkgs-stable.legacyPackages.${system}.tmux;
      keyMode = "vi";
      prefix = "C-b";
      escapeTime = 0;
      extraConfig = ''
        set -g status-interval 0
        set-option -ga terminal-overrides ",xterm-256color:Tc"
      '';

      tmuxinator.enable = true;

      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.tmux-powerline;
        }
      ];
    };

    home.file."${config.xdg.configHome}/tmuxinator/dev.yml".text = builtins.readFile ./layouts/dev.yml;
    home.file."${config.xdg.configHome}/tmux-powerline/config.sh".text = builtins.readFile ./tmux-powerline/config.sh;
    home.file."${config.xdg.configHome}/tmux-powerline/themes/osaka.sh".text = builtins.readFile ./tmux-powerline/osaka.sh;
  };
}
