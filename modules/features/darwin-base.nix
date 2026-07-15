{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake.modules.darwin."base" =
    {
      config,
      pkgs,
      ...
    }:
    {
      # Networking
      networking.dns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      networking.knownNetworkServices = [
        "Wi-Fi"
        "USB 10/100/1000 LAN"
      ];

      # Apps
      # `home-manager` currently has issues adding them to `~/Applications`
      # Issue: https://github.com/nix-community/home-manager/issues/1341
      environment.systemPackages = with pkgs; [
        terminal-notifier
      ];

      # Install and setup ZSH to work with nix(-darwin) as well
      programs.zsh.enable = true;

      # Fonts
      fonts.packages = with pkgs; [
        recursive
        inter
        nerd-fonts.fira-code
        #(nerd-fonts.override {fonts = ["FiraCode"];})
      ];
    };
}
