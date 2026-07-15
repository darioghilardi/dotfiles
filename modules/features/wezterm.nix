{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake.modules.homeManager."wezterm" =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    {
      # Installed with brew, the nix version messes up
      # with the macos dock.
      home.file.".config/wezterm/wezterm.lua".text = ''
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
}
