{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  mkIfCaskPresent = cask: mkIf (lib.any (x: x == cask) config.homebrew.casks);
  brewEnabled = config.homebrew.enable;
in {
  environment.shellInit = mkIf brewEnabled ''
    eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
  '';

  # https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish
  # For some reason if the Fish completions are added at the end of `fish_complete_path` they don't
  # seem to work, but they do work if added at the start.
  programs.fish.interactiveShellInit = mkIf brewEnabled ''
    if test -d (brew --prefix)"/share/fish/completions"
      set -p fish_complete_path (brew --prefix)/share/fish/completions
    end
    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
      set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
  '';

  homebrew.enable = true;
  homebrew.onActivation.upgrade = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.global.brewfile = true;
  homebrew.global.lockfiles = true;

  homebrew.taps = [
    "homebrew/cask"
    "homebrew/cask-drivers"
    "homebrew/cask-fonts"
    "homebrew/cask-versions"
    "homebrew/core"
    "homebrew/services"
    "nrlquaker/createzap"
  ];

  # Prefer installing application from the Mac App Store
  #
  # Commented apps suffer continual update issue:
  # https://github.com/malob/nixpkgs/issues/9
  homebrew.masApps = {
    Keynote = 409183694;
    Numbers = 409203825;
    Pages = 409201541;
    Slack = 803453959;
    "Spark - App email di Readdle" = 1176895641;
    Tailscale = 1475387142;
    "Things 3" = 904280696;
    Twitter = 1482454543;
    "1password for Safari" = 1569813296;
    rcmd = 1596283165;
    amphetamine = 937984704;
    wireguard = 1451685025;
  };

  # If an app isn't available in the Mac App Store, or the version in the App Store has
  # limitiations, e.g., Transmit, install the Homebrew Cask.
  homebrew.casks = [
    "1password-beta"
    "1password-cli"
    "airflow"
    "affinity-designer"
    "alfred"
    "amethyst"
    "cardhop"
    "discord"
    "docker"
    "dropbox"
    "fantastical"
    "figma"
    "firefox"
    "google-chrome"
    "google-drive"
    "linear-linear"
    "meld"
    "microsoft-teams"
    "notion"
    "postman"
    "powershell"
    "qmk-toolbox"
    "rectangle-pro"
    "scummvm"
    "setapp"
    "signal"
    "skype"
    "spotify"
    "steam"
    "sublime-text"
    "telegram-desktop"
    "texturepacker"
    "tor-browser"
    "transmission"
    "transmit"
    "typora"
    "utm"
    "visual-studio-code"
    "vlc"
    "vmware-fusion"
    "whatsapp"
    "zoom"

    # Those other apps comes from setapp:
    # "bettertouchtool"
    # "istat-menus"
    # "tableplus"
    # "sip"
    # "pixelsnap"
  ];

  # Until these are managed by nix.
  homebrew.brews = ["tfenv"]; # [ "asdf" "unixodbc" "wxwidgets" ];

  # Configuration related to casks
  environment.variables.SSH_AUTH_SOCK =
    mkIfCaskPresent "1password-cli"
    "/Users/dario/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
}
