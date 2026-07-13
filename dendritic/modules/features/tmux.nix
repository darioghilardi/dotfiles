{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.homeManager."tmux" = {
    config,
    pkgs,
    ...
  }:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.tools.tmux;
  user = config.dariodots.user;
in {
  options.dariodots.tools.tmux = with types; {
    enable = mkBoolOpt false "Whether or not to enable tmux.";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      package = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.tmux;
      keyMode = "vi";
      prefix = "C-b";
      escapeTime = 0;
      extraConfig = ''
        # Increase scrollback buffer size from 2000 to 50000 lines
        set -g history-limit 50000

        set -g status-interval 0
        set-option -ga terminal-overrides ",xterm-256color:Tc"
        set -g @tmux_power_theme 'moon'
      '';

      tmuxinator.enable = true;

      plugins = with pkgs; [
        tmuxPlugins.tmux-powerline
      ];
    };

    home.file."${config.xdg.configHome}/tmuxinator/dev.yml".text = builtins.readFile ./tmux-data/layouts/dev.yml;
    home.file."${config.xdg.configHome}/tmux-powerline/config.sh".text = builtins.readFile ./tmux-data/tmux-powerline/config.sh;
    home.file."${config.xdg.configHome}/tmux-powerline/themes/tmux-power.sh".text = builtins.readFile ./tmux-data/tmux-powerline/tmux-power.sh;
  };
};
}
