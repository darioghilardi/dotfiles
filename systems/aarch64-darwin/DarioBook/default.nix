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
    # inputs.alejandra.defaultPackage.aarch64-darwin
  ];

  dariodots = {
    apps = {
      ice = enabled;
      lima = enabled;
    };
  };

  nix.package = pkgs.nix.overrideAttrs (old: {
    doCheck = false;
    doInstallCheck = false;

    mesonFlags =
      (old.mesonFlags or [])
      ++ ["-Dunit-tests=false"];
  });

  system.stateVersion = 4;
}
