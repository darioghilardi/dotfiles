{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.apps.ice;
in {
  options.dariodots.apps.ice = with types; {
    enable = mkBoolOpt false "Whether or not to enable `ice`.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ice-bar];
  };
}
