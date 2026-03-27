inputs: final: prev: {
  devenv = inputs.nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.devenv;
}
