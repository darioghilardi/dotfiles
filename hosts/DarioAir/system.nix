{
  lib,
  pkgs,
  ...
}:
with lib;
{
  environment.systemPackages = with pkgs; [
    terminal-notifier
  ];

  system.stateVersion = 4;
}
