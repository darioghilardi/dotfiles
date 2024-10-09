{
  config,
  modulesPath,
  pkgs,
  lib,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  fileSystems."/" = {
    device = "zpool_os/root";
    fsType = "zfs";
  };
  fileSystems."/nix" = {
    device = "zpool_os/nix";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "zpool_os/home";
    fsType = "zfs";
  };

  fileSystems."/var" = {
    device = "zpool_os/var";
    fsType = "zfs";
  };

  fileSystems."/home/storage" = {
    device = "zpool_storage/storage";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-id/ata-CT500MX500SSD1_1834E14E1C41-part1";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  fileSystems."/boot-fallback" = {
    device = "/dev/disk/by-id/ata-ST1000LM024_HN-M101MBB_S2R8J9EC619301-part1";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-id/ata-CT500MX500SSD1_1834E14E1C41-part3";
      randomEncryption = true;
      priority = 1;
    }
    {
      device = "/dev/disk/by-id/ata-ST1000LM024_HN-M101MBB_S2R8J9EC619301-part3";
      randomEncryption = true;
      priority = 2;
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
