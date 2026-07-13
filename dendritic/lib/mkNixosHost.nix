# Phase-A shared assembly for the NixOS hosts: reproduces the snowfall-generated
# nixos toplevel on raw flake-parts, reusing the original module files verbatim.
# Analogous to mkDarwinHost. Given a host's name, target system, and its reused
# system/home files. (Reused files keep their relative paths to ../reused/secrets
# etc., so the reused/ tree mirrors the repo's directory depth.)
{inputs}: {
  hostName,
  system,
  systemModule,
  homeModule,
}: let
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

  extendedLib = lib.extend (final: _prev: {
    dariodots = import ./dariodots {lib = final;};
  });

  collectModules = dir:
    builtins.sort (a: b: (toString a) > (toString b))
    (builtins.filter
      (p: lib.hasSuffix "/default.nix" (toString p))
      (lib.filesystem.listFilesRecursive dir));

  nixosModules = collectModules ../reused/modules/nixos;
  homeModules = collectModules ../reused/home;

  reuseArgs = {
    inherit inputs system;
    namespace = "dariodots"; # `with lib.${namespace}` in the reused nixos modules
    target = system;
    format = "nixos";
    virtual = false;
    systems = {};
    host = hostName;
    home = "dario@${hostName}";
    channels-config = {allowUnfree = true;};
    disko = inputs.disko; # osaka declares a `disko` formal arg (unused in body)
  };

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
  inputs.nixpkgs.lib.nixosSystem {
    modules =
      [
        {nixpkgs.pkgs = pkgs;}
        # flake-utils-plus forces nixpkgs.config empty when providing an external
        # pkgs instance (mkFlake.nix). Required so a host setting nixpkgs.config
        # directly (osaka: allowUnfree) doesn't clash with nixpkgs.pkgs.
        {nixpkgs.config = lib.mkForce {};}
        {system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;}
        # flake-utils-plus (snowfall's base) injects these into every system.
        # On darwin they were inert (nix.enable = false); on nixos they matter.
        {
          nix.package = lib.mkDefault pkgs.nixVersions.latest;
          nix.extraOptions = "extra-experimental-features = nix-command flakes";
          # flake-utils-plus registers the flake itself (options.nix: `nix.registry
          # = { self.flake = flakes.self; }`). The entry embeds the flake's
          # path/rev, so like configurationRevision it only matches once dendritic
          # replaces the root flake.
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
        (wrap systemModule)
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = false;
          home-manager.sharedModules =
            (map wrap homeModules)
            ++ [
              inputs.mac-app-util.homeManagerModules.default
              inputs.nixCats.homeModule
            ];
          home-manager.users.dario.imports = [(wrap homeModule)];
        }
      ]
      ++ (map wrap nixosModules);
  }
