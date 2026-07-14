# Dev shell used by direnv (.envrc = `use flake`). Reproduces the old
# shells/default: jq + deploy-rs + agenix.
{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = [
        pkgs.jq
        inputs.deploy-rs.packages.${system}.deploy-rs
        inputs.agenix.packages.${system}.default
      ];
    };
  };
}
