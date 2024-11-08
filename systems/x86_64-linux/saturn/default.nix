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
    ./hardware-configuration.nix
    ./boot-configuration.nix
  ];

  services.zfs.autoScrub.enable = true;
  systemd.services.zfs-mount.enable = false;

  networking.hostId = "55536429";
  networking.hostName = "saturn";

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
    settings.PasswordAuthentication = true;
    ports = [2222];
    openFirewall = true;
  };

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.sessionVariables = {
    TERM = "xterm-256color";
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    vim
    jq
  ];

  age.secrets = {
    tailscale-key = {file = ../../../secrets/tailscale-key.age;};
  };

  # Clean up packages automatically
  nix.gc = {
    automatic = true;
    dates = "weekly UTC";
  };

  programs.fish.enable = true;

  dariodots.services = {
    tailscale = {
      enable = true;

      autoconnect = {
        enable = true;
        key = "$(cat ${config.age.secrets.tailscale-key.path})";
      };
    };
  };

  users.users = {
    dario = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlcsiLTBnj6tGb5P49Zcg5svvT6qIDLbfar7ac8YLwi"
      ];
    };

    root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlcsiLTBnj6tGb5P49Zcg5svvT6qIDLbfar7ac8YLwi"
      ];
    };
  };

  nix.settings.trusted-users = ["@wheel"];

  security.sudo.enable = true;

  # On activation move existing files by appending the given file
  # extension rather than exiting with an error.
  home-manager.backupFileExtension = "backup";

  system.stateVersion = "24.05";
}
