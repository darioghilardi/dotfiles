{
  description = "Dario's nix system configurations";

  inputs = {
    # Package sets
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Environment/system management
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Other utilities
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
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
        self',
        system,
        ...
      }: {
        formatter = pkgs.alejandra;
      };

      flake = {
        flake-parts,
        flake-utils,
        system,
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

        userInfo = {
          username = "dario";
          fullName = "Dario Ghilardi";
          email = "darioghilardi@webrain.it";
          home = "/Users/dario";
          nixConfigDirectory = "~/dotfiles";
        };

        darwinModules = {
          # My configurations
          dario-bootstrap = import ./darwin/bootstrap.nix;
          dario-defaults = import ./darwin/defaults.nix;
          dario-general = import ./darwin/general.nix;
          dario-homebrew = import ./darwin/homebrew.nix;
          users-primaryUser = import ./darwin/modules/users.nix;
        };
      in {
        # nix-darwin config
        darwinConfigurations = {
          DarioBook = darwinSystem {
            system = "aarch64-darwin";
            modules =
              attrValues darwinModules
              ++ [
                # `home-manager` module
                home-manager.darwinModules.home-manager
                {
                  nixpkgs = nixpkgsConfig;
                  nix.nixPath = {nixpkgs = "${inputs.nixpkgs-unstable}";};

                  networking.computerName = "DarioBook";
                  networking.hostName = "DarioBook";
                  networking.knownNetworkServices = ["Wi-Fi" "USB 10/100/1000 LAN"];

                  users.users.dario = {
                    name = userInfo.username;
                    home = userInfo.home;
                  };

                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    users.dario = import ./home/dariobook.nix;
                  };
                  # Add a registry entry for this flake
                  nix.registry.my.flake = self;
                }
              ];
          };

          DarioAir = darwinSystem {
            system = "aarch64-darwin";
            modules =
              attrValues darwinModules
              ++ [
                # `home-manager` module
                home-manager.darwinModules.home-manager
                {
                  nixpkgs = nixpkgsConfig;
                  nix.nixPath = {nixpkgs = "${inputs.nixpkgs-unstable}";};

                  networking.computerName = "DarioAir";
                  networking.hostName = "DarioAir";
                  networking.knownNetworkServices = ["Wi-Fi" "USB 10/100/1000 LAN"];

                  users.users.dario = {
                    name = userInfo.username;
                    home = userInfo.home;
                  };

                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    users.dario = import ./home/darioair.nix;
                  };
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
      };
    };
}
