#!/bin/sh

# Add the host ssh public key
ssh-copy-id -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" nixos@192.168.65.2

# Copy the install.sh script and make it executable
scp -q -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" scripts/testvm/install.sh nixos@192.168.65.2:/home/nixos/install.sh
ssh -q -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" nixos@192.168.65.2 'chmod +x ~/install.sh'

# Copy the configuration files templates
scp -q -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" scripts/testvm/hardware-configuration.tpl.nix nixos@192.168.65.2:/home/nixos/hardware-configuration.tpl.nix
scp -q -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" scripts/testvm/configuration.tpl.nix nixos@192.168.65.2:/home/nixos/configuration.tpl.nix

# Generate the host ssh keypair
ssh -q -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" nixos@192.168.65.2 'sudo ssh-keygen -t ed25519 -N "" -f /home/ssh_host_ed25519_key'

# Run the install script
ssh -q -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" nixos@192.168.65.2 'sudo ~/install.sh'
