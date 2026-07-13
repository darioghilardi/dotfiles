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
  cfg = config.dariodots.apps.kitty;
in {
  options.dariodots.apps.kitty = with types; {
    enable = mkBoolOpt false "Whether or not to enable `kitty`.";
  };

  config = mkIf cfg.enable {
    # Kitty terminal
    # https://sw.kovidgoyal.net/kitty/conf.html
    programs.kitty = {
      enable = true;
      #theme = "Solarized Dark - Patched";
      shellIntegration.enableFishIntegration = false;

      settings = {
        font_family = "FiraCode Nerd Font Mono";
        font_size = "14.0";
        adjust_line_height = "110%";
        disable_ligatures = "cursor"; # disable ligatures when cursor is on them
        shell_integration = "no-cursor";
        macos_option_as_alt = "yes";

        # Window layout
        window_padding_width = "10";

        # Tab bar
        active_tab_font_style = "bold";
        inactive_tab_font_style = "normal";
        tab_activity_symbol = "";
      };
    };
  };
}
