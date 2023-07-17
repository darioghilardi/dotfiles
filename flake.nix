{
  description = "Dario's nix system configurations";

  inputs = {
    # Package sets
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Environment/system management
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Other utilities
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    darwin,
    flake-parts,
    flake-utils,
    home-manager,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["aarch64-darwin"];

      debug = true;

      perSystem = {
        config,
        pkgs,
        ...
      }: {
        formatter = pkgs.alejandra;
      };

      flake = {
        flake-parts,
        flake-utils,
        ...
      }: let
        inherit (darwin.lib) darwinSystem;
        inherit
          (inputs.nixpkgs-unstable.lib)
          attrValues
          makeOverridable
          optionalAttrs
          singleton
          ;

        # Configuration for `nixpkgs`
        nixpkgsConfig = {
          config = {
            allowUnfree = true;
            allowBroken = true;
          };
          overlays = attrValues self.overlays;
        };

        primaryUserInfo = {
          username = "dario";
          fullName = "Dario Ghilardi";
          email = "darioghilardi@webrain.it";
          home = "/Users/dario";
          nixConfigDirectory = "/Users/dario/dotfiles";
        };
      in {
        # nix-darwin config
        darwinConfigurations = rec {
          DarioBook = darwinSystem {
            system = "aarch64-darwin";
            modules =
              attrValues self.darwinModules
              ++ [
                ./darwin/bootstrap.nix
                # `home-manager` module
                home-manager.darwinModules.home-manager
                {
                  nixpkgs = nixpkgsConfig;
                  nix.nixPath = {nixpkgs = "${inputs.nixpkgs-unstable}";};
                  # `home-manager` config
                  users.users.dario = {
                    name = primaryUserInfo.username;
                    home = primaryUserInfo.home;
                  };

                  networking.computerName = "DarioBook";
                  networking.hostName = "DarioBook";
                  networking.knownNetworkServices = ["Wi-Fi" "USB 10/100/1000 LAN"];

                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.users.dario = import ./home/default.nix;
                  # Add a registry entry for this flake
                  nix.registry.my.flake = self;
                }
              ];
          };
        };

        overlays = import ./overlays/default.nix {
          inputs = inputs;
          nixpkgsConfig = nixpkgsConfig;
          optionalAttrs = optionalAttrs;
        };

        darwinModules = {
          # My configurations
          dario-defaults = import ./darwin/defaults.nix;
          dario-general = import ./darwin/general.nix;
          dario-homebrew = import ./darwin/homebrew.nix;

          users-primaryUser = import ./modules/darwin/users.nix;
        };
      };
    };
}
