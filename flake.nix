{
  description = "Dario's nix system configurations";

  inputs = {
    # Package sets
    nixpkgs-master.url = github:NixOS/nixpkgs/master;
    nixpkgs-stable.url = github:NixOS/nixpkgs/nixpkgs-21.11-darwin;
    nixpkgs-unstable.url = github:NixOS/nixpkgs/nixpkgs-unstable;
    nixos-stable.url = github:NixOS/nixpkgs/nixos-21.11;

    # Environment/system management
    darwin.url = github:LnL7/nix-darwin;
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = github:nix-community/home-manager;
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Other sources
    flake-compat = { url = github:edolstra/flake-compat; flake = false; };
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, darwin, flake-utils, ... }@inputs:
    let
      inherit (darwin.lib) darwinSystem;
      inherit (inputs.nixpkgs-unstable.lib) attrValues makeOverridable optionalAttrs singleton;

      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = attrValues self.overlays;
      };

      # User info
      primaryUserInfo = {
        username = "dario";
        fullName = "Dario Ghilardi";
        email = "darioghilardi@webrain.it";
        nixConfigDirectory = "/Users/dario/.config/nixpkgs";
      };
    in
    {
      # nix-darwin config
      darwinConfigurations = rec {
        # Minimal configurations to bootstrap systems
        bootstrap-x86 = makeOverridable darwinSystem {
          system = "x86_64-darwin";
          modules = [ ./darwin/bootstrap.nix { nixpkgs = nixpkgsConfig; } ];
        };
        bootstrap-arm = bootstrap-x86.override { system = "aarch64-darwin"; };

        # My Apple Silicon macOS laptop config
        DarioBook = darwinSystem {
          system = "aarch64-darwin";
          modules = attrValues self.darwinModules ++ [
            {
              users.primaryUser = primaryUserInfo;
              networking.computerName = "DarioBook";
              networking.hostName = "DarioBook";
              networking.knownNetworkServices = [
                "Wi-Fi"
                "USB 10/100/1000 LAN"
              ];
            }
          ];
        };
      };

      overlays = {
        # Overlay useful on Macs with Apple Silicon
        apple-silicon = final: prev: optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
          # Add access to x86 packages system is running Apple Silicon
          pkgs-x86 = import inputs.nixpkgs-unstable {
            system = "x86_64-darwin";
            inherit (nixpkgsConfig) config;
          };
        }; 
      };
  
      darwinModules = {
        # My configurations
        dario-bootstrap = import ./darwin/bootstrap.nix;
        dario-defaults = import ./darwin/defaults.nix;
        dario-general = import ./darwin/general.nix;
        dario-homebrew = import ./darwin/homebrew.nix;

        users-primaryUser = import ./modules/darwin/users.nix;
      };
    };
}
