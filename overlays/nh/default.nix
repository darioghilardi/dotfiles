inputs: final: prev: {
  nh = inputs.nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.nh;
}
