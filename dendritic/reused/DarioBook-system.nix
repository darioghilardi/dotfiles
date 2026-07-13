{
  lib,
  pkgs,
  inputs,
  channels-config,
  ...
}:
with lib;
with lib.dariodots; {
  environment.systemPackages = with pkgs; [
    terminal-notifier
    deploy-rs
    # inputs.alejandra.defaultPackage.aarch64-darwin
  ];

  nix.package = pkgs.nix.overrideAttrs (old: {
    doCheck = false;
    doInstallCheck = false;

    mesonFlags =
      (old.mesonFlags or [])
      ++ ["-Dunit-tests=false"];
  });

  system.stateVersion = 4;
}
