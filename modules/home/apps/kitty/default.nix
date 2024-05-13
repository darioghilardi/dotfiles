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
}: let
  colors = import ./colors.nix;
in {
  # Kitty terminal
  # https://sw.kovidgoyal.net/kitty/conf.html
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.kitty.enable
  programs.kitty.enable = true;
  programs.kitty.theme = "Solarized Dark - Patched";
  programs.kitty.shellIntegration.enableFishIntegration = false;

  programs.kitty.settings = {
    font_family = "FiraCode Nerd Font Mono";
    font_size = "14.0";
    adjust_line_height = "110%";
    disable_ligatures = "cursor"; # disable ligatures when cursor is on them
    shell_integration = "no-cursor";

    # Window layout
    window_padding_width = "10";

    # Tab bar
    active_tab_font_style = "bold";
    inactive_tab_font_style = "normal";
    tab_activity_symbol = "";
  };
}
