{
  lib,
  home,
  config,
  ...
}:
with lib.dariodots; {
  programs.home-manager.enable = true;

  dariodots = {
    tools = {
      direnv = enabled;
      git = enabled;
    };
    cli-apps = {
      bat = enabled;
      bottom = enabled;
      eza = enabled;
      fzf = enabled;
      htop = enabled;
      jq = enabled;
      k9s = enabled;
      ripgrep = enabled;
      zoxide = enabled;
    };
  };

  home = {
    username = "dario";
    homeDirectory = "/home/dario";

    sessionVariables = {
      EDITOR = "vim";
      TERM = "xterm-256color";
    };

    # Home Manager release
    stateVersion = "24.05";
  };

  manual = {
    manpages.enable = false;
    html.enable = false;
    json.enable = false;
  };
}
