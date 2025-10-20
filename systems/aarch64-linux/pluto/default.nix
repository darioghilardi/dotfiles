{
  lib,
  pkgs,
  inputs,
  namespace,
  system,
  target,
  format,
  systems,
  config,
  ...
}:
with lib;
with lib.${namespace}; {
  imports = [
    ./configuration.nix
  ];

  # environment.systemPackages = with pkgs; [
  #   curl
  #   git
  #   vim
  #   jq
  # ];

  services.openssh = {
    enable = true;
  };

  programs.fish.enable = true;

  users.users = {
    dario = {
      isNormalUser = true;
      home = "/home/dario.linux";
      group = "users";
      extraGroups = ["wheel"];
      shell = pkgs.fish;
    };
  };

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "pluto";

  security.sudo.wheelNeedsPassword = false;

  # On activation move existing files by appending the given file
  # extension rather than exiting with an error.
  home-manager.backupFileExtension = "backup";

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    # Give users in the `wheel` group additional rights when connecting to the Nix daemon
    # This simplifies remote deployment to the instance's nix store.
    trusted-users = ["@wheel"];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly UTC";
  };

  system.stateVersion = "25.11";
}
