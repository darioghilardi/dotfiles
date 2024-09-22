#!/bin/sh

set -ev

# Destroy zpool
# zfs destroy -r zpool
# zpool destroy zpool

# Umount everything
# umount /mnt/boot
# umount /mnt/boot-fallback

# umount /dev/vda1
# wipefs -a /dev/vda1

# umount /dev/vda2
# wipefs -a /dev/vda2

# umount /dev/vdb1
# wipefs -a /dev/vdb1

# umount /dev/vdb2
# wipefs -a /dev/vdb2

# Apparently not needed
# partprobe /dev/vda

DISK1='/dev/vda'
DISK2='/dev/vdb'

BOOT1='/dev/vda1'
BOOT2='/dev/vdb1'
OS1='/dev/vda2'
OS2='/dev/vdb2'
SWAP1='/dev/vda3'
SWAP2='/dev/vdb3'

CRYPTED1='crypted-1'
CRYPTED2='crypted-2'

SWAPSIZE=8

# Create a new partition table
parted -s $DISK1 -- mklabel gpt

# Create ESP/Boot partition at the beginning of the disk
parted -s $DISK1 -- mkpart ESP fat32 1MiB 512MiB
parted -s $DISK1 -- set 1 boot on

# Create the storage partition
parted -s $DISK1 -- mkpart primary 512MiB -$((SWAPSIZE))GiB

# Create the swap partition
parted -s $DISK1 -- mkpart swap -${SWAPSIZE}GiB 100%

# Clone the partition scheme to the other disk
sfdisk --dump $DISK1 | sfdisk $DISK2

# Create ESP partitions
mkfs.vfat $BOOT1
mkfs.vfat $BOOT2

# Create the swap partitions
mkswap $SWAP1
mkswap $SWAP2

# Activate the swap partitions
swapon $SWAP1
swapon $SWAP2

# Create the encrypted LUKS containers
echo "password" | cryptsetup luksFormat --type luks1 --hash sha256 --iter-time 3000 --use-random $OS1
echo "password" | cryptsetup luksOpen $OS1 $CRYPTED1

echo "password" | cryptsetup luksFormat --type luks1 --hash sha256 --iter-time 3000 --use-random $OS2
echo "password" | cryptsetup luksOpen $OS2 $CRYPTED2

# Check status of LUKS container
sudo cryptsetup -v status $CRYPTED1
sudo cryptsetup -v status $CRYPTED2

# Create the zfs zpool
zpool create -f -o ashift=12 -O mountpoint=none -O acltype=posixacl -O xattr=sa -O compression=zstd zpool mirror /dev/mapper/$CRYPTED1 /dev/mapper/$CRYPTED2

# Print the zpool status
zpool status

# Create zfs filesystem
zfs create -o mountpoint=legacy zpool/root
zfs create -o mountpoint=legacy zpool/home
zfs create -o mountpoint=legacy zpool/nix
zfs create -o mountpoint=legacy zpool/var

# Print the filesystems
zfs list

# Mount the filesystem
mount -t zfs zpool/root /mnt

# Create the directories to mount filesystem on
mkdir -p /mnt/{nix,home,var,boot,boot-fallback}

# Mount the rest of the ZFS filesystem
mount -t zfs zpool/nix /mnt/nix
mount -t zfs zpool/home /mnt/home
mount -t zfs zpool/var /mnt/var

# Mount both of the ESP's
mount $BOOT1 /mnt/boot
mount $BOOT2 /mnt/boot-fallback

# Check mounted directories
ls -la /mnt

# Generate the nixos configuration
nixos-generate-config --root /mnt

# Get disks boot partitions UUIDs
VDA1_UUID=$(lsblk -no UUID $BOOT1)
VDB1_UUID=$(lsblk -no UUID $BOOT2)

# Get disks data OS partitions UUIDs
VDA2_UUID=$(blkid $OS1 -s UUID -o value)
VDB2_UUID=$(blkid $OS2 -s UUID -o value)

# Get swap partuuids
# FIXME: partuuid is the same on a vm
SWAP1_PARTUUID=$(blkid $SWAP1 -s PARTUUID -o value)
SWAP2_PARTUUID=$(blkid $SWAP2 -s PARTUUID -o value)

# Disable systemd-boot
sed -i '/boot.loader.systemd-boot.enable/d' /mnt/etc/nixos/configuration.nix
sed -i '/boot.loader.efi.canTouchEfiVariables/d' /mnt/etc/nixos/configuration.nix
sed -i '/Use the systemd-boot/d' /mnt/etc/nixos/configuration.nix

# Add a file with the grub config to be pushed to configuration.nix
cat <<EOT >> boot-config.txt
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.enableCryptodisk = true;

  # Needed when the installer is booted in legacy mode but you
  # want to boot in UEFI mode
  boot.loader.grub.efiInstallAsRemovable = true;

  # This will mirror all UEFI files, kernels, grub menus and things
  # needed to boot to the other drive.
  boot.loader.grub.mirroredBoots = [
    { devices = [ "/dev/disk/by-uuid/${VDA1_UUID}" ]; path = "/boot"; }
    { devices = [ "/dev/disk/by-uuid/${VDB1_UUID}" ]; path = "/boot-fallback"; }
  ];

  boot.initrd = {
    supportedFilesystems = [ "zfs" ];

    # Modules that were working on the conf without ssh unlock
    # availableKernelModules = [ "xhci_pci" "sr_mod" "virtio-pci" ];

    availableKernelModules = [ "xhci_pci" "sr_mod" "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio" ];
    kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" "virtio_gpu" ];

    # Not sure
    # systemd.users.root.shell = "/bin/cryptsetup-askpass";

    # This should speed up the zsf import at boot
    postDeviceCommands = "zpool import -a -d -f /dev/disk/by-uuid";

    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222; 
        hostKeys = [ /home/ssh_host_ed25519_key ];
        authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlcsiLTBnj6tGb5P49Zcg5svvT6qIDLbfar7ac8YLwi" ];
      };
    };

    luks.devices = {
      root = {
        device = "/dev/disk/by-uuid/$VDA2_UUID";
        preLVM = true;
      };
      root2 = {
        device = "/dev/disk/by-uuid/$VDB2_UUID";
        preLVM = true;
      };
    };
  };

  boot.kernelParams = [ "ip=dhcp" ];
  boot.supportedFilesystems = [ "zfs" ];

  boot.zfs.extraPools = [ "zpool" ];
  boot.zfs.devNodes = "/dev/disk/by-uuid";

  services.zfs.autoScrub.enable = true;
  # systemd.services.zfs-mount.enable = false;
  systemd-boot.enable = false;

  networking.hostId = "37636429";
  networking.useDHCP = true;

  swapDevices = [{
    device = "/dev/disk/by-partuuid/$SWAP1_PARTUUID";
    randomEncryption = true;
    priority = 1;
  } {
    device = "/dev/disk/by-partuuid/$SWAP2_PARTUUID";
    randomEncryption = true;
    priority = 2;
  }];
EOT

# Add grub configuration
sed -i $'/networking.hostName/{e cat boot-config.txt\n}' /mnt/etc/nixos/configuration.nix 

# Add random encryption to swap
sed -i '/Use the systemd-boot/d' /mnt/etc/nixos/configuration.nix

# Remove availableKernelModules from hardware-configuration.nix
sed -i '/boot.initrd.availableKernelModules/d' /mnt/etc/nixos/hardware-configuration.nix
sed -i '/boot.initrd.kernelModules/d' /mnt/etc/nixos/hardware-configuration.nix

# Remove autogenerated swap configuration
sed -i '/swapDevices/,+4d' /mnt/etc/nixos/hardware-configuration.nix