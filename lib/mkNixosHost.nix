# Shared assembly for the NixOS hosts: builds a nixos toplevel on raw flake-parts
# from a host's system/home module files (under ../hosts/<name>) plus the
# dendritic aspect modules it selects. Analogous to mkDarwinHost; called by
# modules/hosts/<name>.nix. Host files reference ../../secrets and ../../keys.
{ inputs }:
{
  hostName,
  system,
  systemModule,
  homeModule,
  # Dendritic aspect modules (see modules/features/*) composed into the system
  # and home configs — the nixos/home feature set this host enables.
  nixosAspects ? [ ],
  homeAspects ? [ ],
}:
let
  inherit (inputs.nixpkgs) lib;

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
inputs.nixpkgs.lib.nixosSystem {
  modules = [
    # Provide the flake `inputs` to plain host modules (system.nix references
    # them) without specialArgs; aspect modules get inputs via closure.
    {
      nixpkgs.pkgs = pkgs;
      _module.args.inputs = inputs;
    }
    # flake-utils-plus forces nixpkgs.config empty when providing an external
    # pkgs instance (mkFlake.nix). Required so a host setting nixpkgs.config
    # directly (osaka: allowUnfree) doesn't clash with nixpkgs.pkgs.
    { nixpkgs.config = lib.mkForce { }; }
    { system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null; }
    # flake-utils-plus (snowfall's base) injects these into every system.
    # On darwin they were inert (nix.enable = false); on nixos they matter.
    {
      nix.package = lib.mkDefault pkgs.nixVersions.latest;
      nix.extraOptions = "extra-experimental-features = nix-command flakes";
      # flake-utils-plus registers the flake itself (options.nix: `nix.registry
      # = { self.flake = flakes.self; }`). Reproduced so `nix` commands on the
      # host resolve `self` to this flake.
      nix.registry.self.flake = inputs.self;
    }
    # snowfall auto-created the user via `snowfallorg.users.<n>` (create=true):
    # isNormalUser + name/home/group as mkDefaults. The host's system file
    # merges its own extraGroups/shell/keys on top.
    {
      users.users.dario = {
        isNormalUser = lib.mkDefault true;
        name = lib.mkDefault "dario";
        home = lib.mkDefault "/home/dario";
        group = lib.mkDefault "users";
      };
    }
    # External nixos modules (from the old flake's systems.modules.nixos).
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.vscode-server.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    systemModule
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = false;
      home-manager.sharedModules = homeAspects ++ [
        inputs.mac-app-util.homeManagerModules.default
        inputs.nixCats.homeModule
      ];
      home-manager.users.dario.imports = [ homeModule ];
    }
  ]
  ++ nixosAspects;
}
