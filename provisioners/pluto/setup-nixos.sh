#!/bin/bash
# This script sets up a newly created Lima-NixOS guest by checking out
# both a NixOS system configuration from Git and rebuilding NixOS.
set -eux

# Name of NixOS default configuration to apply (from the repo's flake.nix)
CONFIG_NAME='pluto'
# Git Repo containing a flake.nix containing NixOS configurations
# In the sample the repo is the same as Home Manager repo, but they can be different
CONFIG_REPO='https://github.com/darioghilardi/dotfiles.git'

# Name of Lima VM (Guest Host), required parameter
HOST_NAME='pluto'

set +x
echo
echo Configuring \"$HOST_NAME\" using \""$CONFIG_REPO#$CONFIG_NAME"\"
echo
set -x

# Checkout $CONFIG_REPO containing your NixOS host configuration flake
limactl shell $HOST_NAME -- sudo git clone $CONFIG_REPO /etc/nixos
limactl shell $HOST_NAME -- sudo nixos-rebuild boot --flake /etc/nixos#$CONFIG_NAME
sleep 0.1
limactl stop $HOST_NAME
limactl start $HOST_NAME
