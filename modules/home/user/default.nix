{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.user;

  is-linux = pkgs.stdenv.isLinux;
  is-darwin = pkgs.stdenv.isDarwin;

  home-directory =
    if cfg.name == null
    then null
    else if is-darwin
    then "/Users/${cfg.username}"
    else "/home/${cfg.username}";
in {
  options.dariodots.user = with types; {
    fullName = mkOpt str "Dario Ghilardi" "Full name of the user.";
    username = mkOpt str "dario" "Account name of the user.";
    email = mkOpt str "darioghilardi@webrain.it" "Email of the user.";
    homeDir = mkOpt str home-directory "Home directory of the user.";
  };

  config = {
    home = {
      username = mkDefault cfg.username;
      homeDirectory = mkDefault cfg.homeDir;
    };
  };
}
