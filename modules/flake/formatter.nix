{
  # The RFC 166 standard Nix formatter (nixfmt), wrapped by treefmt so `nix fmt`
  # recurses the tree and honours .gitignore. `perSystem` is flake-parts'
  # per-target scope; `pkgs` is the nixpkgs instance for the current system.
  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixfmt-tree;
  };
}
