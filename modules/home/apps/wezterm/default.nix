{
  lib,
  pkgs,
  inputs,
  system,
  target,
  format,
  virtual,
  systems,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.apps.wezterm;
in {
  options.dariodots.apps.wezterm = with types; {
    enable = mkBoolOpt false "Whether or not to enable `wezterm`.";
  };

  config = mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      extraConfig = ''
        local wezterm = require 'wezterm'
        local config = wezterm.config_builder()

        return {
          front_end = "WebGpu",
          font = wezterm.font("JetBrains Mono"),
          font_size = 14.0,
          freetype_load_target = 'Light',
          freetype_render_target = 'HorizontalLcd',
          color_scheme = 'Solarized Dark - Patched',
          cell_width = 0.9,
          hide_tab_bar_if_only_one_tab = true,
          use_fancy_tab_bar = true,
        }
      '';
    };
  };
}
