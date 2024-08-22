{
  inputs,
  pkgs,
  mkShell,
  system,
  ...
}: let
  deploy-rs = inputs.deploy-rs.packages.${system}.deploy-rs;
in
  mkShell {
    packages = with pkgs; [
      jq
      deploy-rs
    ];
  }
