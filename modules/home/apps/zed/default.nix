{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.apps.zed;
in {
  # Zed configuration (zed installed through brew for now)

  options.dariodots.apps.zed = with types; {
    enable = mkBoolOpt false "Whether or not to enable `Zed` configurations.";
  };

  config = mkIf cfg.enable {
    home.file.".config/zed/settings.json".text = ''
      {
        "ui_font_size": 16,
        "buffer_font_size": 14,
        "vim_mode": true
      }
    '';
  };
}
