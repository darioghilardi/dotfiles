#!/bin/sh

set -ev

export DISK_KEY_1=$1
export DISK_KEY_2=$2

# Available disks
# Use the hardware id for identification as stated here:
# https://unix.stackexchange.com/questions/559655/how-to-correctly-get-the-uuid-of-the-entire-disk
export DISK_OS_1='/dev/disk/by-id/ata-CT500MX500SSD1_1834E14E1C41'
export DISK_OS_2='/dev/disk/by-id/ata-ST1000LM024_HN-M101MBB_S2R8J9EC619301'
export DISK_STORAGE_1='/dev/disk/by-id/ata-WDC_WD40EFPX-68C6CN0_WD-WX22D24C9VZJ'
export DISK_STORAGE_2='/dev/disk/by-id/ata-WDC_WD40EFPX-68C6CN0_WD-WX22D24DMPCR'

# Disk OS partitions
export BOOT_1='/dev/disk/by-id/ata-CT500MX500SSD1_1834E14E1C41-part1'
export BOOT_2='/dev/disk/by-id/ata-ST1000LM024_HN-M101MBB_S2R8J9EC619301-part1'
export OS_1='/dev/disk/by-id/ata-CT500MX500SSD1_1834E14E1C41-part2'
export OS_2='/dev/disk/by-id/ata-ST1000LM024_HN-M101MBB_S2R8J9EC619301-part2'
export SWAP_1='/dev/disk/by-id/ata-CT500MX500SSD1_1834E14E1C41-part3'
export SWAP_2='/dev/disk/by-id/ata-ST1000LM024_HN-M101MBB_S2R8J9EC619301-part3'
export CRYPTED_OS_1='crypted-os-1'
export CRYPTED_OS_2='crypted-os-2'

# Disk storage partitions
export STORAGE_1='/dev/disk/by-id/ata-WDC_WD40EFPX-68C6CN0_WD-WX22D24C9VZJ-part1'
export STORAGE_2='/dev/disk/by-id/ata-WDC_WD40EFPX-68C6CN0_WD-WX22D24DMPCR-part1'
export CRYPTED_STORAGE_1='crypted-storage-1'
export CRYPTED_STORAGE_2='crypted-storage-2'

export SWAPSIZE=8
export ZFS_REFRESERVATION=10

partition_disk_os() {
  # Create a new partition table
  parted -s $DISK_OS_1 -- mklabel gpt

  # Create ESP/Boot partition at the beginning of the disk
  parted -s $DISK_OS_1 -- mkpart ESP fat32 1MiB 512MiB
  parted -s $DISK_OS_1 -- set 1 boot on

  # Create the storage partition
  parted -s $DISK_OS_1 -- mkpart primary 512MiB -$((SWAPSIZE))GiB

  # Create the swap partition
  parted -s $DISK_OS_1 -- mkpart swap -${SWAPSIZE}GiB 100%

  # Clone the partition scheme to the other disk and wait for the operation to finish
  sfdisk --dump $DISK_OS_1 | sfdisk $DISK_OS_2
  sleep 2

  # Create ESP partitions
  mkfs.vfat $BOOT_1
  mkfs.vfat $BOOT_2

  # Create the swap partitions
  mkswap $SWAP_1
  mkswap $SWAP_2

  # Activate the swap partitions
  swapon $SWAP_1
  swapon $SWAP_2
}

encrypt_disk_os() {
  # Create the encrypted LUKS containers
  echo $DISK_KEY_1 | cryptsetup luksFormat --type luks1 --hash sha256 --iter-time 3000 --use-random $OS_1
  echo $DISK_KEY_1 | cryptsetup luksOpen $OS_1 $CRYPTED_OS_1

  echo $DISK_KEY_1 | cryptsetup luksFormat --type luks1 --hash sha256 --iter-time 3000 --use-random $OS_2
  echo $DISK_KEY_1 | cryptsetup luksOpen $OS_2 $CRYPTED_OS_2

  # Check status of LUKS container
  sudo cryptsetup -v status $CRYPTED_OS_1
  sudo cryptsetup -v status $CRYPTED_OS_2
}

create_zpool_os() {
  # Create the zfs zpool
  zpool create \
  -f \
  -o ashift=12 \
  -O acltype=posixacl \
  -O atime=off \
  -O compression=zstd \
  -O dnodesize=auto \
  -O mountpoint=none \
  -O normalization=formD \
  -O relatime=on \
  -O xattr=sa \
  zpool_os \
  mirror \
  /dev/mapper/$CRYPTED_OS_1 \
  /dev/mapper/$CRYPTED_OS_2

  # Print the zpool status
  zpool status

  # Create zfs filesystem
  zfs create -o mountpoint=legacy zpool_os/root
  zfs create -o mountpoint=legacy zpool_os/home
  zfs create -o mountpoint=legacy zpool_os/nix
  zfs create -o mountpoint=legacy zpool_os/var
  zfs create -o canmount=off -o mountpoint=none -o refreservation=$((ZFS_REFRESERVATION))G zpool_os/reserved

  # Print the filesystems
  zfs list
}

partition_disk_storage() {
  # Create a new partition table
  parted -s $DISK_STORAGE_1 -- mklabel gpt

  # Create the storage partition
  parted -s $DISK_STORAGE_1 -- mkpart primary 0% 100%

  # Clone the partition scheme to the other disk and wait for the operation to finish
  sfdisk --dump $DISK_STORAGE_1 | sfdisk $DISK_STORAGE_2
  sleep 2
}

encrypt_disk_storage() {
  # Create the encrypted LUKS containers
  echo $DISK_KEY_2 | cryptsetup luksFormat --type luks1 --hash sha256 --iter-time 3000 --use-random $STORAGE_1
  echo $DISK_KEY_2 | cryptsetup luksOpen $STORAGE_1 $CRYPTED_STORAGE_1

  echo $DISK_KEY_2 | cryptsetup luksFormat --type luks1 --hash sha256 --iter-time 3000 --use-random $STORAGE_2
  echo $DISK_KEY_2 | cryptsetup luksOpen $STORAGE_2 $CRYPTED_STORAGE_2

  # Check status of LUKS container
  sudo cryptsetup -v status $CRYPTED_STORAGE_1
  sudo cryptsetup -v status $CRYPTED_STORAGE_2
}

create_zpool_storage() {
  # Create the zfs zpool
  zpool create \
  -f \
  -O acltype=posixacl \
  -O atime=off \
  -O compression=zstd \
  -O dnodesize=auto \
  -O mountpoint=none \
  -O normalization=formD \
  -O recordsize=1M \
  -O relatime=on \
  -O xattr=sa \
  -o ashift=12 \
  zpool_storage \
  mirror \
  /dev/mapper/$CRYPTED_STORAGE_1 \
  /dev/mapper/$CRYPTED_STORAGE_2

  # Print the zpool status
  zpool status

  # Create zfs filesystem
  zfs create -o mountpoint=legacy zpool_storage/storage
  zfs create -o canmount=off -o mountpoint=none -o refreservation=$((ZFS_REFRESERVATION))G zpool_storage/reserved

  # Print the filesystems
  zfs list
}

mount_filesystems() {
  # Mount the filesystem
  mount -t zfs zpool_os/root /mnt

  # Create the directories to mount filesystem on
  mkdir -p /mnt/{nix,home,var,boot,boot-fallback}

  # Mount the rest of the ZFS filesystem
  mount -t zfs zpool_os/nix /mnt/nix
  mount -t zfs zpool_os/home /mnt/home
  mount -t zfs zpool_os/var /mnt/var

  # Create the storage directory in home
  mkdir -p /mnt/home/storage

  # Mount the storage zpool
  mount -t zfs zpool_storage/storage /mnt/home/storage

  # Mount both of the ESP's
  mount $BOOT_1 /mnt/boot
  mount $BOOT_2 /mnt/boot-fallback

  # Check mounted directories
  ls -la /mnt
}

partition_disk_os
encrypt_disk_os
create_zpool_os
partition_disk_storage
encrypt_disk_storage
create_zpool_storage
mount_filesystems

# Generate the nixos configuration
nixos-generate-config --root /mnt

# Install gettext to use envsubst
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update
nix-env --install --attr nixpkgs.gettext

# Replace hardware-configuration.nix and configuration.nix
cat /home/nixos/hardware-configuration.tpl.nix | envsubst > /mnt/etc/nixos/hardware-configuration.nix
cat /home/nixos/configuration.tpl.nix | envsubst > /mnt/etc/nixos/configuration.nix
