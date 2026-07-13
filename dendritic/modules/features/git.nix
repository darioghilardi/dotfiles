{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.homeManager."git" = {
    config,
    pkgs,
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

      ignores = [".DS_Store"];

      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };

        extraConfig = {
          color.ui = "auto";
          init = {defaultBranch = "master";};
          core.editor = "code --wait";
        };

        # Enhanced diffs
        delta.enable = true;
      };
    };
  };
};
}
