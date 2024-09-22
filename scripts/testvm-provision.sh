#!/bin/sh

ssh-copy-id -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" nixos@192.168.65.2
scp -q -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" scripts/testvm-install.sh nixos@192.168.65.2:/home/nixos/installer.sh
ssh -q -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" nixos@192.168.65.2 'chmod +x ~/installer.sh'
ssh -q -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" nixos@192.168.65.2 'sudo ssh-keygen -t ed25519 -N "" -f /home/ssh_host_ed25519_key'
ssh -q -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" nixos@192.168.65.2 'sudo ~/installer.sh'
