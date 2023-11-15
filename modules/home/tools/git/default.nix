{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.tools.git;
  user = config.dariodots.user;
in {
  options.dariodots.tools.git = with types; {
    enable = mkBoolOpt false "Whether or not to enable git.";
    userName = mkOpt str user.fullName "The name to configure git with.";
    userEmail = mkOpt str user.email "The email to configure git with.";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;

      inherit (cfg) userName userEmail;

      ignores = [".DS_Store"];
      extraConfig = {
        color.ui = "auto";
        init = {defaultBranch = "master";};
      };

      # Enhanced diffs
      delta.enable = true;
    };
  };
}
