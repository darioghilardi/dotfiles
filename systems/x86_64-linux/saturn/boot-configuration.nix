{
  config,
  modulesPath,
  pkgs,
  lib,
  ...
}: {
  boot.kernelModules = ["kvm-intel"];
  boot.kernelParams = ["ip=192.168.8.102::192.168.8.1:255.255.255.0:saturn::none"];
  boot.extraModulePackages = [];

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
        devices = ["/dev/disk/by-id/ata-CT500MX500SSD1_1834E14E1C41-part1"];
        path = "/boot";
      }
      {
        devices = ["/dev/disk/by-id/ata-ST1000LM024_HN-M101MBB_S2R8J9EC619301-part1"];
        path = "/boot-fallback";
      }
    ];
  };

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.extraPools = ["zpool_os" "zpool_storage"];
  boot.zfs.devNodes = "/dev/disk/by-id";

  boot.initrd = {
    supportedFilesystems = ["zfs"];
    availableKernelModules = ["xhci_pci" "ehci_pci" "ata_piix" "usbhid" "usb_storage" "sd_mod" "r8169"];
    kernelModules = [];

    # Wait a bit before starting
    # See https://github.com/NixOS/nixpkgs/issues/98741
    preLVMCommands = "sleep 1";

    luks.devices = {
      os_1 = {
        device = "/dev/disk/by-id/ata-CT500MX500SSD1_1834E14E1C41-part2";
        preLVM = true;
      };
      os_2 = {
        device = "/dev/disk/by-id/ata-ST1000LM024_HN-M101MBB_S2R8J9EC619301-part2";
        preLVM = true;
      };
      storage_1 = {
        device = "/dev/disk/by-id/ata-WDC_WD40EFPX-68C6CN0_WD-WX22D24C9VZJ-part1";
        preLVM = true;
      };
      storage_2 = {
        device = "/dev/disk/by-id/ata-WDC_WD40EFPX-68C6CN0_WD-WX22D24DMPCR-part1";
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
      # This is not working properly.
      # postCommands = "/bin/cryptsetup-askpass";
    };

    # This speeds up the zpool import on boot otherwise it takes 2 minutes.
    postDeviceCommands = "zpool import -a -f -d /dev/mapper";
  };
}
