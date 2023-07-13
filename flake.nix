{
  description = "Dario's nix system configurations";

  inputs = {
    # Package sets
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Environment/system management
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Other sources
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, darwin, home-manager, flake-utils, ... }@inputs:
  let
      inherit (self.lib) attrValues makeOverridable mkForce optionalAttrs singleton;

      # This value determines the Home Manager release that your
      # configuration is compatible with. This helps avoid breakage
      # when a new Home Manager release introduces backwards
      # incompatible changes.
      #
      # You can update Home Manager without changing this value. See
      # the Home Manager release notes for a list of state version
      # changes in each release.
      homeStateVersion = "23.11";

      # Configuration for `nixpkgs`
      nixpkgsDefaults = {
        config = {
          allowUnfree = true;
          allowBroken = true;
        };
        overlays = attrValues self.overlays;
      };

      primaryUserDefaults = {
        username = "dario";
        fullName = "Dario Ghilardi";
        email = "darioghilardi@webrain.it";
        nixConfigDirectory = "/Users/dario/.config/nixpkgs";
      };

    in {

      # Add some additional functions to `lib`.
      lib = inputs.nixpkgs-unstable.lib.extend (_: _: {
        mkDarwinSystem = import ./lib/mkDarwinSystem.nix inputs;
      });

      # Overlays --------------------------------------------------------------------------------{{{

      overlays = {
        # Overlays to add different versions `nixpkgs` into package set
        pkgs-master = _: prev: {
          pkgs-master = import inputs.nixpkgs-master {
            inherit (prev.stdenv) system;
            inherit (nixpkgsDefaults) config;
          };
        };
        pkgs-stable = _: prev: {
          pkgs-stable = import inputs.nixpkgs-stable {
            inherit (prev.stdenv) system;
            inherit (nixpkgsDefaults) config;
          };
        };
        pkgs-unstable = final: prev: {
          pkgs-unstable = import inputs.nixpkgs-unstable {
            inherit (prev.stdenv) system;
            inherit (nixpkgsDefaults) config;
          };
        };

        # Overlay useful on Macs with Apple Silicon
        apple-silicon = final: prev:
          optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
            # Add access to x86 packages system is running Apple Silicon
            pkgs-x86 = import inputs.nixpkgs-unstable {
              system = "x86_64-darwin";
              inherit (nixpkgsDefaults) config;
            };
          };

        # Overlay that adds `lib.colors` to reference colors elsewhere in system configs
        colors = import ./overlays/colors.nix;
      };

      # Modules -------------------------------------------------------------------------------- {{{

      darwinModules = {
        # My configurations
        dario-defaults = import ./darwin/defaults.nix;
        dario-general = import ./darwin/general.nix;
        dario-homebrew = import ./darwin/homebrew.nix;

        users-primaryUser = import ./modules/darwin/users.nix;
      };

      homeManagerModules = {
        dario-colors = import ./home/colors.nix;
        dario-fish = import ./home/fish.nix;
        dario-git = import ./home/git.nix;
        dario-kitty = import ./home/kitty.nix;
        dario-packages = import ./home/packages.nix;
        dario-starship = import ./home/starship.nix;

        colors = import ./modules/home/colors;
        programs-kitty-extras = import ./modules/home/programs/kitty/extras.nix;
        home-user-info = { lib, ... }: {
          options.home.user-info =
            (self.darwinModules.users-primaryUser { inherit lib; }).options.users.primaryUser;
        };
      };

      # System configurations ------------------------------------------------------------------ {{{

      darwinConfigurations = {
        # Minimal macOS configurations to bootstrap systems
        bootstrap-x86 = makeOverridable darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [ ./darwin/bootstrap.nix { nixpkgs = nixpkgsDefaults; } ];
        };
        bootstrap-arm = self.darwinConfigurations.bootstrap-x86.override {
          system = "aarch64-darwin";
        };

        DarioBook = makeOverridable self.lib.mkDarwinSystem (primaryUserDefaults // {
          modules = attrValues self.darwinModules ++ singleton {
            nixpkgs = nixpkgsDefaults;
            networking.computerName = "DarioBook";
            networking.hostName = "DarioBook";
            networking.knownNetworkServices = [
              "Wi-Fi"
              "USB 10/100/1000 LAN"
            ];
            nix.registry.my.flake = inputs.self;
          };

          extraModules = singleton { nix.linux-builder.enable = true; };
          inherit homeStateVersion;
          homeModules = attrValues self.homeManagerModules;

            # # `home-manager` module
            # home-manager.darwinModules.home-manager
            # {
            #   nixpkgs = nixpkgsDefaults;


            #   nix.nixPath = { nixpkgs = "${inputs.nixpkgs-unstable}"; };
            #   # `home-manager` config
            #   users.users.dario = {
            #     home = "/Users/dario";
            #     name = "dario";
            #   };

            #   home-manager.useGlobalPkgs = true;
            #   home-manager.useUserPackages = true;


            #   home-manager.users.dario = { pkgs, ... }: {
            #     home.stateVersion = homeStateVersion;
            #     home.username = primaryUserDefaults.username;
            #     home.homeDirectory = "/Users/${primaryUserDefaults.username}";
            #     home.sessionVariables = { EDITOR = "nvim"; };
            #   };
            # }
            # ];
        });
      };

    };
}
