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

  # Trick to assign the correct permissions to the
  # /home/storage folder.
  systemd.tmpfiles.settings = {
    "10-mypackage" = {
      "/home/storage" = {
        z = {
          group = "users";
          mode = "0755";
          user = "dario";
        };
      };
    };
  };

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

  environment.systemPackages = with pkgs; [
    curl
    git
    vim
    jq
  ];

  age.secrets = {
    "tailscale-key".file = ../../../secrets/tailscale-key.age;
    "restic/env".file = ../../../secrets/restic/env.age;
    "restic/repo".file = ../../../secrets/restic/repo.age;
    "restic/password".file = ../../../secrets/restic/password.age;
    "healthchecks/borgbackup" = {
      file = ../../../secrets/healthchecks/borgbackup.age;
      owner = "borgbackup";
      group = "borgbackup";
      mode = "0400";
    };
  };

  # Clean up packages automatically
  nix.gc = {
    automatic = true;
    dates = "weekly UTC";
  };

  dariodots.services = {
    nfs = {
      enable = true;
      exports = [
        {
          path = "/home/storage";
          clients = "100.64.0.0/10";
          options = "rw,sync,no_subtree_check,insecure,all_squash,anonuid=1000,anongid=100";
        }
      ];
    };

    tailscale = {
      enable = true;
      autoconnect = {
        enable = true;
        key = config.age.secrets."tailscale-key".path;
      };
    };

    restic = {
      enable = true;
      paths = ["/home/storage"];
      envFile = config.age.secrets."restic/env".path;
      repositoryFile = config.age.secrets."restic/repo".path;
      passwordFile = config.age.secrets."restic/password".path;
    };

    borgbackup = {
      enable = true;
      paths = ["/home/storage"];
      repo = "ssh://u433810@u433810.your-storagebox.de:23/./backups/saturn";
      passwordFile = config.age.secrets."borgbackup/password".path;
      healthchecksUrlFile = config.age.secrets."healthchecks/borgbackup".path;
    };
  };

  programs.fish.enable = true;

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
