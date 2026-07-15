# Shared assembly for the aarch64-darwin hosts: builds a darwin toplevel on raw
# flake-parts from a host's system/home module files (under ../hosts/<name>) plus
# the dendritic aspect modules it selects. Called by modules/hosts/<name>.nix.
{ inputs }:
{
  hostName,
  systemModule,
  homeModule,
  # Dendritic aspect modules (see modules/features/*) composed into the system
  # and home configs — the darwin/home feature set this host enables.
  darwinAspects ? [ ],
  homeAspects ? [ ],
}:
let
  inherit (inputs.nixpkgs) lib;
  system = "aarch64-darwin";

  # pkgs built the same way snowfall's channel did: allowUnfree + the repo's
  # three overlays. useGlobalPkgs (below) makes home-manager reuse this exact
  # instance, so the overlay'd packages (nh, devenv, direnv) match.
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      (import ../overlays/nh inputs)
      (import ../overlays/devenv inputs)
      (import ../overlays/direnv inputs)
    ];
  };

in
inputs.darwin.lib.darwinSystem {
  modules = [
    # Provide the flake `inputs` to plain host modules (system.nix references
    # them) without specialArgs; aspect modules get inputs via closure.
    {
      nixpkgs.pkgs = pkgs;
      _module.args.inputs = inputs;
    }
    # snowfall set this automatically from the flake's git rev; reproduced
    # explicitly here. Resolves to the commit rev (or dirtyRev on a dirty
    # working tree, null if not a git flake).
    { system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null; }
    # snowfall derived the hostname from the system directory name.
    # localHostName defaults to hostName, so this emits both
    # `scutil --set HostName/LocalHostName`.
    { networking.hostName = hostName; }
    # snowfall auto-created the darwin user via its `snowfallorg.users.<n>`
    # abstraction (create=true). Reproduced directly: home-manager derives
    # home.username/homeDirectory from this.
    {
      users.users.dario = {
        home = lib.mkDefault "/Users/dario";
        isHidden = lib.mkDefault false;
      };
    }
    inputs.mac-app-util.darwinModules.default
    inputs.home-manager.darwinModules.home-manager
    systemModule
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = false;
      # Home features are aspect modules selected per-host (see the caller's
      # homeAspects list). Order is not significant.
      home-manager.sharedModules = homeAspects ++ [
        inputs.mac-app-util.homeManagerModules.default
        inputs.nixCats.homeModule
      ];
      home-manager.users.dario.imports = [ homeModule ];
    }
  ]
  ++ darwinAspects;
}
