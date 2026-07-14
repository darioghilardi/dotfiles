{
  lib,
  pkgs,
  ...
}:
with lib; {
  environment.systemPackages = with pkgs; [
    terminal-notifier
    # inputs.alejandra.defaultPackage.aarch64-darwin
  ];

  system.stateVersion = 4;
}
