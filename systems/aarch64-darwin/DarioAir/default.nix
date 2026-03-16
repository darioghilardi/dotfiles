{
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.dariodots; {
  environment.systemPackages = with pkgs; [
    terminal-notifier
    inputs.alejandra.defaultPackage.aarch64-darwin
  ];

  dariodots = {
    apps = {
      ice = enabled;
    };
  };

  system.stateVersion = 4;
}
