{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.darwin."system" = {
    config,
    pkgs,
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
    ApplePressAndHoldEnabled = false;
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
};
}
