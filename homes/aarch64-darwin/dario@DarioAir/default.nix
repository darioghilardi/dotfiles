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
      ssh = {
        enable = true;
        use1Password = true;
      };
    };
    cli-apps = {
      bat = enabled;
      bottom = enabled;
      eza = enabled;
      fzf = enabled;
      gh = enabled;
      htop = enabled;
      jq = enabled;
      k9s = enabled;
      lazygit = enabled;
      neovim = enabled;
      ripgrep = enabled;
      tmux = enabled;
      zellij = enabled;
      zoxide = enabled;
      #awscli = enabled;
    };
    apps = {
      zed = enabled;
      kitty = enabled;
    };
  };

  programs.home-manager.enable = true;

  home = {
    username = "dario";
    homeDirectory = "/Users/dario";
    sessionVariables = {EDITOR = "nvim";};

    # Home Manager release
    stateVersion = "24.05";
  };

  # Fixes some weird compilation bug
  manual = {
    manpages.enable = false;
    html.enable = false;
    json.enable = false;
  };
}
