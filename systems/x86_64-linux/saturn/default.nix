{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.
  # All other arguments come from the system system.
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

  #services.tailscale.enable = true;

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
