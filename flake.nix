{
  description = "Dario's nix system configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-lib = {
      url = "github:snowfallorg/lib?ref=v3.0.3";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    deploy-rs,
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
      systems.modules.nixos = with inputs; [disko.nixosModules.disko];

      deploy = lib.mkDeploy {
        inherit (inputs) self;

        overrides = {
          saturn.remoteBuild = true;
          saturn.sshUser = "root";
          saturn.profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.saturn;
          };
        };
      };

      outputs-builder = channel: {
        # Outputs in the outputs builder are transformed to support each system.
        checks = inputs.deploy-rs.lib.${channel.nixpkgs.system}.deployChecks self.deploy;
        formatter = channel.nixpkgs.alejandra;
      };
    };
}
