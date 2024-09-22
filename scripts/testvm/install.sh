#!/bin/sh

set -ev

export DISK1='/dev/vda'
export DISK2='/dev/vdb'

export BOOT1='/dev/vda1'
export BOOT2='/dev/vdb1'
export OS1='/dev/vda2'
export OS2='/dev/vdb2'
export SWAP1='/dev/vda3'
export SWAP2='/dev/vdb3'

export CRYPTED1='crypted-1'
export CRYPTED2='crypted-2'

export SWAPSIZE=8

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

# Get disks boot partitions UUIDs
export VDA1_UUID=$(lsblk -no UUID $BOOT1)
export VDB1_UUID=$(lsblk -no UUID $BOOT2)

# Get disks data OS partitions UUIDs
export VDA2_UUID=$(blkid $OS1 -s UUID -o value)
export VDB2_UUID=$(blkid $OS2 -s UUID -o value)

# Get swap partuuids
export SWAP1_PARTUUID=$(blkid $SWAP1 -s PARTUUID -o value)
export SWAP2_PARTUUID=$(blkid $SWAP2 -s PARTUUID -o value)

# Generate the nixos configuration
nixos-generate-config --root /mnt

# Install gettext to use envsubst
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update
nix-env --install --attr nixpkgs.gettext

# Replace hardware-configuration.nix and configuration.nix
cat /home/nixos/hardware-configuration.tpl.nix | envsubst > /mnt/etc/nixos/hardware-configuration.nix
cat /home/nixos/configuration.tpl.nix | envsubst > /mnt/etc/nixos/configuration.nix
