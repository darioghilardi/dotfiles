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
  disko,
  ...
}:
with lib;
with lib.${namespace}; {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ./users.nix
    ./secrets.nix
  ];

  environment.systemPackages = with pkgs; [
    clang
    curl
    git
    vim
    jq
  ];

  services.vscode-server.enable = true;
  programs.nix-ld.enable = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
    settings.PasswordAuthentication = false;
    knownHosts = {
      "github/ed25519" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        hostNames = [ "github.com" ];
      };
    };
  };

  programs.fish.enable = true;

  virtualisation.docker.enable = true;

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ALL = "en_US.UTF-8";
  };

  networking.hostName = "osaka";
  networking.hostId = "cfcfbe32";
  networking.firewall.enable = false;

  # On activation move existing files by appending the given file
  # extension rather than exiting with an error.
  home-manager.backupFileExtension = "backup";

  # For parallels, as /mnt/psf doesn't exist on nixos by default
  systemd.tmpfiles.rules = [
    "d /mnt/psf 0777 dario users -"
    "d /media/psf 0777 dario users -"
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.gc.automatic = true;
  nix.gc.dates = "weekly UTC";

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
