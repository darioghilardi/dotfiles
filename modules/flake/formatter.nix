{
  # Mirrors the old `outputs-builder`'s `formatter = channel.nixpkgs.alejandra`.
  # `perSystem` is flake-parts' per-target scope; `pkgs` is the nixpkgs
  # instance for the current system.
  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;
  };
}
