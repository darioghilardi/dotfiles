# osaka home. Feature selection lives in the host module (homeAspects list).
# home.username/homeDirectory come from the nixos user (users.users.dario).
{...}: {
  programs.home-manager.enable = true;

  home.stateVersion = "25.05";

  manual = {
    manpages.enable = false;
    html.enable = false;
    json.enable = false;
  };
}
