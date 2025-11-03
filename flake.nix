{
  description = "Dario's nix system configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
    deploy-rs,
    mac-app-util,
    ...
  } @ inputs: let
    inherit (inputs) deploy-rs;

    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;

      snowfall = {
        meta = {
          name = "dariodots";
          title = "DarioDots";
        };

        namespace = "dariodots";
      };
    };
  in
    lib.mkFlake {
      # External modules only for nixos
      systems.modules.nixos = with inputs; [
        agenix.nixosModules.default
      ];

      # External modules only for darwin
      systems.modules.darwin = with inputs; [
        mac-app-util.darwinModules.default
      ];

      # External modules for home-manager
      homes.modules = with inputs; [
        mac-app-util.homeManagerModules.default
      ];

      deploy = lib.mkDeploy {
        inherit (inputs) self;

        overrides = {
          saturn = {
            remoteBuild = true;
            interactiveSudo = false;
            sshUser = "root";
            sshOpts = ["-p" "2222"];
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.activate.nixos self.nixosConfigurations.saturn;
            };
          };

          # pluto = {
          #   remoteBuild = true;
          #   interactiveSudo = false;
          #   sshUser = "dario";
          #   sshOpts = ["-p" "50006" "-i" "~/.lima/_config/user" "-o" "NoHostAuthenticationForLocalhost=yes"];
          #   profiles.system = {
          #     user = "root";
          #     path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.pluto;
          #   };
          # };
        };
      };

      outputs-builder = channel: {
        # Outputs in the outputs builder are transformed to support each system.
        formatter = channel.nixpkgs.alejandra;
      };
    };
}
