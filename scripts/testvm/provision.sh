#!/bin/sh

set -e

ADDRESS=$1
TARGET=nixos@$ADDRESS
ssh_opts=( -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" )

# Add the host ssh public key
ssh-copy-id "${ssh_opts[@]}" $TARGET

# Copy the install.sh script and make it executable
scp -q "${ssh_opts[@]}" scripts/testvm/install.sh $TARGET:/home/nixos/install.sh
ssh -q "${ssh_opts[@]}" $TARGET 'chmod +x ~/install.sh'

# Copy the configuration files templates
scp -q "${ssh_opts[@]}" scripts/testvm/hardware-configuration.tpl.nix $TARGET:/home/nixos/hardware-configuration.tpl.nix
scp -q "${ssh_opts[@]}" scripts/testvm/configuration.tpl.nix $TARGET:/home/nixos/configuration.tpl.nix

# Run the install script
read -s -p "Disk encryption key OS: " KEY_OS
read -s -p "Disk encryption key Storage: " KEY_STORAGE
ssh -q "${ssh_opts[@]}" $TARGET "sudo ~/install.sh $KEY_OS $KEY_STORAGE"

# Generate the host ssh keypair
ssh -q "${ssh_opts[@]}" $TARGET 'sudo mkdir -p /mnt/etc/ssh'
ssh -q "${ssh_opts[@]}" $TARGET 'sudo ssh-keygen -t ed25519 -N "" -f /mnt/etc/ssh/ssh_host_ed25519_key'
