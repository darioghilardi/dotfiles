{
  description = "Dario's nix system configurations";

  inputs = {
    # Nixpkgs unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # MacOS Support
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Snowfall Lib
    snowfall-lib.url = "github:snowfallorg/lib?ref=v2.1.1";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";
    snowfall-lib.inputs.flake-utils-plus.url = "github:fl42v/flake-utils-plus";

    # Other utilities
    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall = {
        namespace = "dariodots";
        meta = {
          name = "dariodots";
          title = "DarioDots";
        };
      };
    };

  # # Configuration for `nixpkgs`
  # nixpkgsConfig = {
  #   config = {
  #     allowUnfree = true;
  #     allowBroken = true;
  #   };
  #   overlays = attrValues self.overlays;
  # };

  # darwinModules = {
  #   in {
  #     # nix-darwin config
  #     darwinConfigurations = {
  #       DarioBook = darwinSystem {
  #         system = "aarch64-darwin";
  #         modules =
  #           attrValues darwinModules
  #           ++ [
  #             # `home-manager` module
  #             home-manager.darwinModules.home-manager
  #             {
  #               nixpkgs = nixpkgsConfig;
  #               nix.nixPath = {nixpkgs = "${inputs.nixpkgs-unstable}";};

  #               networking.computerName = "DarioBook";
  #               networking.hostName = "DarioBook";
  #               networking.knownNetworkServices = ["Wi-Fi" "USB 10/100/1000 LAN"];

  #               users.users.dario = {
  #                 name = userInfo.username;
  #                 home = userInfo.home;
  #               };

  #               home-manager = {
  #                 useGlobalPkgs = true;
  #                 useUserPackages = true;
  #                 users.dario = import ./home/dariobook.nix;
  #               };
  #               # Add a registry entry for this flake
  #               nix.registry.my.flake = self;
  #             }
  #           ];
  #       };
}
