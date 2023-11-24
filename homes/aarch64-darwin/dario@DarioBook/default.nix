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
      git = enabled;
    };
    cli-apps = {
      bat = enabled;
      bottom = enabled;
      eza = enabled;
      fzf = enabled;
      gh = enabled;
      htop = enabled;
      jq = enabled;
      neovim = enabled;
      ripgrep = enabled;
      tmux = enabled;
      zoxide = enabled;
      #awscli = enabled;
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
