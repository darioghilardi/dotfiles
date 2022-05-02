{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Dario Ghilardi";
    userEmail = "darioghilardi@webrain.it";
    ignores = [ ".DS_Store" ];
    extraConfig = {
      color.ui = "auto";
      init = { defaultBranch = "master"; };
    };
  };

  programs.git.delta.enable = true;
}
