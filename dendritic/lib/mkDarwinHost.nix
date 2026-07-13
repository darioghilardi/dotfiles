# Phase-A shared assembly for the aarch64-darwin hosts: reproduces the
# snowfall-generated darwin toplevel on raw flake-parts, reusing the original
# module files verbatim (under ../reused). Goal: byte-identical store path vs
# the root flake. Given a host's name + its reused system/home files.
#
# This is Phase-A scaffolding (it reuses snowfall-shaped class modules); it goes
# away when features become native aspect files in Phase B.
{inputs}: {
  hostName,
  systemModule,
  homeModule,
  # Dendritic aspect modules (Phase B) composed alongside the still-reused
  # class modules. As features convert, they move from ../reused into these.
  darwinAspects ? [],
  homeAspects ? [],
}: let
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

  # nixpkgs.lib extended with the project's `dariodots` helpers, mirroring
  # snowfall's lib injection. Passed to reused modules as their `lib` arg by the
  # wrapper below (a plain function call, so it bypasses the module system's
  # fixed `lib` — no specialArgs needed, and the reused files stay byte-identical
  # with `with lib.dariodots;` intact).
  extendedLib = lib.extend (final: _prev: {
    dariodots = import ./dariodots {lib = final;};
  });


  # Values the reused snowfall modules expect. Shared by lexical closure — NOT
  # via specialArgs (banned) nor _module.args (which recurses for helpers used
  # while building the option tree). Only `inputs`/`dariodots` are read in
  # bodies; the rest satisfy formal arguments and are unused.
  reuseArgs = {
    inherit inputs system;
    target = system;
    format = "darwin";
    virtual = false;
    systems = {};
    host = hostName;
    home = "dario@${hostName}";
    channels-config = {allowUnfree = true;};
  };

  # Wrap a reused module so it receives `reuseArgs` + the extended `lib`,
  # alongside the real config/pkgs/options from whichever module system evaluates
  # it (nix-darwin for darwin modules, home-manager for home modules).
  wrap = modPath: {
    config,
    pkgs,
    options,
    ...
  }:
    import modPath ({
        inherit config pkgs options;
        lib = extendedLib;
      }
      // reuseArgs);
in
  inputs.darwin.lib.darwinSystem {
    modules =
      [
        {nixpkgs.pkgs = pkgs;}
        # snowfall set this automatically from the flake's git rev. Reproduced
        # explicitly. As a path: flake during migration `self.rev` is absent, so
        # it's null now (matching a dirty build); once dendritic is promoted to
        # the repo root it resolves to the commit, restoring parity.
        {system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;}
        # snowfall derived the hostname from the system directory name.
        # localHostName defaults to hostName, so this emits both
        # `scutil --set HostName/LocalHostName`.
        {networking.hostName = hostName;}
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
        (wrap systemModule)
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = false;
          # Home features are now aspect modules (Phase B), passed in snowfall's
          # merge order (see home-feature-order.nix) so ordered options like
          # home.packages / fish init stay byte-identical.
          home-manager.sharedModules =
            homeAspects
            ++ [
              inputs.mac-app-util.homeManagerModules.default
              inputs.nixCats.homeModule
            ];
          home-manager.users.dario.imports = [(wrap homeModule)];
        }
      ]
      ++ darwinAspects;
  }
