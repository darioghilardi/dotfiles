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
    ./hardware.nix
  ];

  boot = {
    loader.grub.enable = true;

    initrd.availableKernelModules = ["ata_piix" "usbhid"];
    initrd.kernelModules = [];

    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  time.timeZone = "Europe/Rome";

  networking = {
    hostName = "saturn";
    useDHCP = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [22];
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    gitMinimal
    jq
    neovim
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

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

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

  security.sudo = {
    enable = true;
  };

  system.stateVersion = "24.05";
}
