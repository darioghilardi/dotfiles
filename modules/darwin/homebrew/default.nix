{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.
  # All other arguments come from the module system.
  config,
  ...
}: let
  inherit (lib) mkIf;

  mkIfCaskPresent = cask: mkIf (lib.any (x: x == cask) config.homebrew.casks);

  brewEnabled = config.homebrew.enable;

  casks = [
    "1password@beta"
    "1password-cli@beta"
    "airflow"
    "affinity"
    "alfred"
    "balenaetcher"
    "discord"
    # Stopped working on 22/7/25
    # "docker"
    # Stopped working on 21/4/25
    # "dropbox"
    "figma"
    "firefox"
    "google-chrome"
    "google-drive"
    "inkscape"
    "keka"
    "keyboard-maestro"
    "kobo"
    "linear-linear"
    "microsoft-teams"
    "notion"
    "omnidisksweeper"
    "postman"
    "powershell"
    "qmk-toolbox"
    "rectangle-pro"
    # setapp is commented because it gets uninstalled by brew all
    # the times, even if it says "updated".
    # "setapp"
    "signal"
    "spotify"
    "steam"
    "sublime-text"
    "telegram-desktop"
    # "tor-browser"
    "transmission"
    "transmit"
    "typora"
    "utm"
    "visual-studio-code"
    "vlc"
    "whatsapp"
    "zed"
    "zoom"
  ];

  # Compute the casks likt to set the greedy attribute on all casks.
  greedyCasks =
    builtins.map (c: {
      name = c;
      greedy = true;
    })
    casks;
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

  # Note: homebrew needs to be installed manually.
  homebrew.enable = true;
  homebrew.global.brewfile = true;
  homebrew.onActivation = {
    upgrade = true;
    autoUpdate = true;
    cleanup = "zap";
  };

  homebrew.taps = [
    "homebrew/cask-fonts"
    "homebrew/cask-versions"
    "homebrew/services"
    "nrlquaker/createzap"
    "cloudflare/cloudflare"
  ];

  # Prefer installing application from the Mac App Store
  #
  # Commented apps suffer continual update issue:
  # https://github.com/malob/nixpkgs/issues/9
  homebrew.masApps = {
    "GIPHY Capture. The GIF Maker" = 668208984;
    Keynote = 409183694;
    Numbers = 409203825;
    Pages = 409201541;
    Slack = 803453959;
    "Spark - App email di Readdle" = 1176895641;
    Tailscale = 1475387142;
    "Things 3" = 904280696;
    Twitter = 1482454543;
    "1password for Safari" = 1569813296;
    wireguard = 1451685025;
  };

  # If an app isn't available in the Mac App Store, or the version in the App Store has
  # limitiations, e.g., Transmit, install the Homebrew Cask.
  homebrew.casks = greedyCasks;

  # Until these are managed by nix.
  homebrew.brews = ["awscli" "php" "duckdb" "cloudflare/cloudflare/cf-terraforming"]; # [ "unixodbc" "wxwidgets" ];

  # Configuration related to casks
  environment.variables.SSH_AUTH_SOCK =
    mkIfCaskPresent "1password-cli@beta"
    "/Users/dario/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
}
