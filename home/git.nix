{ config, pkgs, ... }:

{
  programs.git.enable = true;

  programs.git.userName = "Dario Ghilardi";
  programs.git.userEmail = "darioghilardi@webrain.it";
  programs.git.ignores = [ ".DS_Store" ];
  programs.git.extraConfig = {
    color.ui = "auto";
    init = { defaultBranch = "master"; };
  };

  # Enhanced diffs
  programs.git.delta.enable = true;

  # GitHub CLI
  programs.gh.enable = true;
  programs.gh.settings = {
    git_protocol = "https";
    prompt = "enabled";
  };
}
