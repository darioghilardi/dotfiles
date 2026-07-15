# DarioBook home. Feature selection lives in the host module (homeAspects list);
# this holds only the host's own home settings + the per-host 1Password SSH key.
{ ... }: {
  programs.home-manager.enable = true;

  home.username = "dario";
  home.homeDirectory = "/Users/dario";
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.stateVersion = "24.05";

  # 1Password SSH key item (the ssh aspect provides everything else).
  home.file.".config/1Password/ssh/agent.toml".text = ''
    [[ssh-keys]]
    item = "DarioBook SSH Key"
    vault = "Private"
  '';

  # Fixes some weird compilation bug
  manual = {
    manpages.enable = false;
    html.enable = false;
    json.enable = false;
  };
}
