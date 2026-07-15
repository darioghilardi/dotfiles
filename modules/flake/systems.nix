{
  # The systems flake-parts iterates over for `perSystem` outputs
  # (formatter, devShells, packages, …). Host toplevels are built per host,
  # not from this list, so it only needs the platforms we actually evaluate on.
  systems = [
    "aarch64-darwin"
    "x86_64-linux"
    "aarch64-linux"
  ];
}
