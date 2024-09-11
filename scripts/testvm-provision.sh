#!/bin/sh

ssh-copy-id nixos@192.168.65.2
scp -q -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" scripts/testvm-install.sh nixos@192.168.65.2:/home/nixos/installer.sh
ssh -q -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" nixos@192.168.65.2 'chmod +x ~/installer.sh'
ssh -q -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" nixos@192.168.65.2 'sudo ~/installer.sh'
