{
  inputs,
  pkgs,
  mkShell,
  system,
  ...
}: let
  deploy-rs = inputs.deploy-rs.packages.${system}.deploy-rs;
  agenix = inputs.agenix.packages.${system}.default;
in
  mkShell {
    packages = with pkgs; [
      jq
      deploy-rs
      agenix
    ];
  }
