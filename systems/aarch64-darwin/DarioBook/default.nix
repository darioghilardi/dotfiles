{
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    kitty
    terminal-notifier
    inputs.alejandra.defaultPackage.aarch64-darwin
  ];

  system.stateVersion = 4;
}
