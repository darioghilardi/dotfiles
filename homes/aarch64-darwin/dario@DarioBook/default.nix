{
  lib,
  home,
  config,
  ...
}:
with lib.dariodots; {
  dariodots = {
    tools = {
      direnv = enabled;
    };
  };

  programs.home-manager.enable = true;

  home = {
    username = "dario";
    homeDirectory = "/Users/dario";
    sessionVariables = {EDITOR = "nvim";};

    # Home Manager release
    stateVersion = "23.11";
  };

  # Fixes some weird compilation bug
  manual = {
    manpages.enable = false;
    html.enable = false;
    json.enable = false;
  };
}
