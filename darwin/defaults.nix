{
  system.defaults.NSGlobalDomain = {
    # scroll direction
    "com.apple.swipescrolldirection" = false;
    # Keyboard key repeat
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
    
  };

  # Dock and Mission Control
  system.defaults.dock = {
    autohide = false;
    tilesize = 32;
  };

  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
}
