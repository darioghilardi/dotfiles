# saturn home. Feature selection lives in the host module (homeAspects list).
{ ... }: {
  programs.home-manager.enable = true;

  home = {
    username = "dario";
    homeDirectory = "/home/dario";
    sessionVariables = {
      EDITOR = "vim";
      TERM = "xterm-256color";
    };
    stateVersion = "24.05";
  };

  manual = {
    manpages.enable = false;
    html.enable = false;
    json.enable = false;
  };
}
