# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.kernelModules = [];
  boot.extraModulePackages = [];

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
    device = "/dev/disk/by-uuid/$SDA1_UUID";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  fileSystems."/boot-fallback" = {
    device = "/dev/disk/by-uuid/$SDB1_UUID";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/$SWAP1_PARTUUID";
      randomEncryption = true;
      priority = 1;
    }
    {
      device = "/dev/disk/by-partuuid/$SWAP2_PARTUUID";
      randomEncryption = true;
      priority = 2;
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
