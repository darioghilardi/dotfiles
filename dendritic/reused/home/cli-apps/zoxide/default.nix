{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.zoxide;
in {
  # Zoxide, a faster way to navigate the filesystem
  # https://github.com/ajeetdsouza/zoxide

  options.dariodots.cli-apps.zoxide = with types; {
    enable = mkBoolOpt false "Whether or not to enable `zoxide`.";
  };

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
