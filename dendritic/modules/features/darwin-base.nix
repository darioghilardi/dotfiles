{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.modules.darwin."base" = {
    config,
    pkgs,
    ...
  }: {
  # Networking
  networking.dns = ["1.1.1.1" "8.8.8.8"];
  networking.knownNetworkServices = ["Wi-Fi" "USB 10/100/1000 LAN"];

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
    terminal-notifier
    # inputs.alejandra.defaultPackage.aarch64-darwin
  ];

  # Add shells installed by nix to /etc/shells file
  environment.shells = with pkgs; [bashInteractive fish zsh];

  # Make Fish the default shell
  programs.fish.enable = true;
  programs.fish.useBabelfish = true;
  programs.fish.babelfishPackage = pkgs.babelfish;
  # Needed to address bug where $PATH is not properly set for fish:
  # https://github.com/LnL7/nix-darwin/issues/122
  programs.fish.shellInit = ''
    for p in (string split : ${config.environment.systemPath})
      if not contains $p $fish_user_paths
        set -g fish_user_paths $fish_user_paths $p
      end
    end
  '';
  environment.variables.SHELL = "${pkgs.fish}/bin/fish";

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
