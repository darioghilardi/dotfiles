{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.
  # All other arguments come from the module system.
  config,
  ...
}: {
  services.nix-daemon.enable = true;

  nix.settings = {
    substituters = ["https://cache.nixos.org/"];
    trusted-public-keys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
    trusted-users = ["@admin"];
  };

  # TODO: remove when the issue with curl is fixed
  # https://github.com/curl/curl/issues/15496
  nix.package = let
    patched-curl = pkgs.curl.overrideAttrs (oldAttrs: {
      patches =
        (oldAttrs.patches or [])
        ++ [
          # https://github.com/curl/curl/issues/15496
          (pkgs.fetchpatch {
            url = "https://github.com/curl/curl/commit/f5c616930b5cf148b1b2632da4f5963ff48bdf88.patch";
            hash = "sha256-FlsAlBxAzCmHBSP+opJVrZG8XxWJ+VP2ro4RAl3g0pQ=";
          })
          # https://github.com/curl/curl/issues/15513
          (pkgs.fetchpatch {
            url = "https://github.com/curl/curl/commit/0cdde0fdfbeb8c35420f6d03fa4b77ed73497694.patch";
            hash = "sha256-WP0zahMQIx9PtLmIDyNSJICeIJvN60VzJGN2IhiEYv0=";
          })
        ];
    });
  in
    pkgs.nixVersions.nix_2_25.override {
      curl = patched-curl;
    };

  nix.configureBuildUsers = true;
}
