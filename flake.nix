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

    # Other sources
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    darwin,
    flake-utils,
    home-manager,
    ...
  } @ inputs: let
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
                home = "/Users/dario";
                name = "dario";
              };

              networking.computerName = "DarioBook";
              networking.hostName = "DarioBook";
              networking.knownNetworkServices = ["Wi-Fi" "USB 10/100/1000 LAN"];

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.dario = import ./home/home.nix;
              # Add a registry entry for this flake
              nix.registry.my.flake = self;
            }
          ];
      };
    };

    overlays = {
      # Overlays to add different versions `nixpkgs` into package set
      pkgs-master = final: prev: {
        pkgs-master = import inputs.nixpkgs-master {
          inherit (prev.stdenv) system;
          inherit (nixpkgsConfig) config;
        };
      };
      pkgs-stable = final: prev: {
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit (prev.stdenv) system;
          inherit (nixpkgsConfig) config;
        };
      };
      pkgs-unstable = final: prev: {
        pkgs-unstable = import inputs.nixpkgs-unstable {
          inherit (prev.stdenv) system;
          inherit (nixpkgsConfig) config;
        };
      };

      # Overlay useful on Macs with Apple Silicon
      apple-silicon = final: prev:
        optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
          # Add access to x86 packages system is running Apple Silicon
          pkgs-x86 = import inputs.nixpkgs-unstable {
            system = "x86_64-darwin";
            inherit (nixpkgsConfig) config;
          };
        };

      # Overlay that adds `lib.colors` to reference colors elsewhere in system configs
      colors = import ./overlays/colors.nix;
    };

    darwinModules = {
      # My configurations
      dario-defaults = import ./darwin/defaults.nix;
      dario-general = import ./darwin/general.nix;
      dario-homebrew = import ./darwin/homebrew.nix;

      users-primaryUser = import ./modules/darwin/users.nix;
    };
  };
}
