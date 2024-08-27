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

  boot.initrd.availableKernelModules = ["xhci_pci" "sr_mod"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = [];
  boot.extraModulePackages = [];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  time.timeZone = "Europe/Rome";

  networking = {
    hostName = "testvm";
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
