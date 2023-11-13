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

  # General config ----------------------------------------------------------------------------- {{{

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

  programs.kitty.theme = "Solarized Dark";

  # Change the style of italic font variants
  # programs.kitty.extraConfig = ''
  #   font_features FiraCodeNerdFontCompleteM-Retina +cv01 +cv06
  # '';

  # programs.kitty.extras.useSymbolsFromNerdFont = "FiraCode Nerd Font Mono";
  # }}}
}
