{
  lib,
  pkgs,
  ...
}:
with lib;
{
  environment.systemPackages = with pkgs; [
    terminal-notifier
    deploy-rs
  ];

  nix.package = pkgs.nix.overrideAttrs (old: {
    doCheck = false;
    doInstallCheck = false;

    mesonFlags = (old.mesonFlags or [ ]) ++ [ "-Dunit-tests=false" ];
  });

  system.stateVersion = 4;
}
