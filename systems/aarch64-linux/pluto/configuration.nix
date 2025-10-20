{
  config,
  modulesPath,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # system mounts
  boot = {
    kernelParams = ["console=tty0"];
    loader.grub = {
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };
  fileSystems."/boot" = {
    device = lib.mkForce "/dev/vda1"; # /dev/disk/by-label/ESP
    fsType = "vfat";
  };
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
    options = ["noatime" "nodiratime" "discard"];
  };

  # misc
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
