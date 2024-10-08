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
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    enableCryptodisk = true;

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
        devices = ["${BOOT_1}"];
        path = "/boot";
      }
      {
        devices = ["${BOOT_2}"];
        path = "/boot-fallback";
      }
    ];
  };

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.extraPools = ["zpool_os" "zpool_storage"];
  boot.zfs.devNodes = "/dev/disk/by-id";

  boot.kernelParams = ["ip=192.168.8.102::192.168.8.1:255.255.255.0:saturn::none"];

  boot.initrd = {
    supportedFilesystems = ["zfs"];
    availableKernelModules = ["xhci_pci" "ehci_pci" "ata_piix" "usbhid" "usb_storage" "sd_mod" "r8169"];
    kernelModules = [];

    # Wait a bit before starting
    # See https://github.com/NixOS/nixpkgs/issues/98741
    preLVMCommands = "sleep 1";

    luks.devices = {
      os_1 = {
        device = "$OS_1";
        preLVM = true;
      };
      os_2 = {
        device = "$OS_2";
        preLVM = true;
      };
      storage_1 = {
        device = "$STORAGE_1";
        preLVM = true;
      };
      storage_2 = {
        device = "$STORAGE_2";
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

      # FIXME:
      # This is not working at boot, need to run the command manually when
      # connecting through ssh.
      # postCommands = "/bin/cryptsetup-askpass";
    };

    # This speeds up the zpool import on boot otherwise it takes 2 minutes.
    postDeviceCommands = "zpool import -a -f -d /dev/mapper";
  };

  services.zfs.autoScrub.enable = true;
  systemd.services.zfs-mount.enable = false;

  networking.hostId = "55536429";
  networking.hostName = "saturn"; # Define your hostname.

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
    passwordAuthentication = true;
    ports = [2222];
    openFirewall = true;
  };

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

  system.stateVersion = "24.05";
}
