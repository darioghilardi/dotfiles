# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    enableCryptodisk = true;

    # Needed when the installer is booted in legacy mode but you
    # want to but in UEFI mode
    efiInstallAsRemovable = true;

    # Add extra entries on grub
    extraEntries = ''
      menuentry "Reboot" {
        reboot
      }
      menuentry "Poweroff" {
        halt
      }
    '';

    # This will mirror all UEFI files, kernels, grub menus and things
    # needed to boot to the other drive.
    mirroredBoots = [
      {
        devices = ["/dev/disk/by-uuid/${SDA1_UUID}"];
        path = "/boot";
      }
      {
        devices = ["/dev/disk/by-uuid/${SDC1_UUID}"];
        path = "/boot-fallback";
      }
    ];
  };

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.extraPools = ["zpool_os" "zpool_storage"];
  boot.zfs.devNodes = "/dev/disk/by-uuid";

  boot.initrd = {
    supportedFilesystems = ["zfs"];
    availableKernelModules = ["virtio_net" "virtio_pci" "xhci_pci" "sr_mod"];
    kernelModules = [];

    # Wait a bit before starting
    # See https://github.com/NixOS/nixpkgs/issues/98741
    preLVMCommands = "sleep 1";

    luks.devices = {
      os_1 = {
        device = "/dev/disk/by-uuid/$SDA2_UUID";
        preLVM = true;
      };
      os_2 = {
        device = "/dev/disk/by-uuid/$SDC2_UUID";
        preLVM = true;
      };
      storage_1 = {
        device = "/dev/disk/by-uuid/$SDB1_UUID";
        preLVM = true;
      };
      storage_2 = {
        device = "/dev/disk/by-uuid/$SDD1_UUID";
        preLVM = true;
      };
    };

    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 9999;
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlcsiLTBnj6tGb5P49Zcg5svvT6qIDLbfar7ac8YLwi"
        ];
        hostKeys = ["/etc/ssh/ssh_host_ed25519_key"];
      };

      postCommands = "/bin/cryptsetup-askpass";
    };

    # This speeds up the zpool import on boot otherwise it takes 2 minutes.
    postDeviceCommands = "zpool import -a -f -d /dev/mapper";
  };

  services.zfs.autoScrub.enable = true;
  systemd.services.zfs-mount.enable = false;

  networking.hostId = "55536429";
  networking.hostName = "saturn"; # Define your hostname.

  networking.firewall.allowedTCPPorts = [22];

  time.timeZone = "Europe/Rome";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.dario = {
    isNormalUser = true;
    extraGroups = ["wheel"];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
