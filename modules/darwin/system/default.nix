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
}: {
  system.defaults.NSGlobalDomain = {
    # scroll direction
    "com.apple.swipescrolldirection" = false;

    # mouse speed cannot be set yet
    # https://github.com/LnL7/nix-darwin/pull/452
    # °com.apple.mouse.scaling" = 3;

    # keyboard key repeat
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
  };

  # Dock and Mission Control
  system.defaults.dock = {
    autohide = false;
    tilesize = 32;
    show-recents = false;
    wvous-bl-corner = 3;
    wvous-br-corner = 11;
    wvous-tl-corner = 2;
    wvous-tr-corner = 4;
  };

  # Firewall
  system.defaults.finder = {
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
    ShowStatusBar = true;
    ShowPathbar = true;
  };

  system.defaults.loginwindow.GuestEnabled = false;

  system.defaults.magicmouse = {MouseButtonMode = "TwoButton";};

  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.primaryUser = "dario";
}
