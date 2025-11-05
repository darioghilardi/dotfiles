# Osaka

Osaka is the development virtual machine running on MacOS, based on NixOS and running on Parallels.

To create this machine from scratch, two steps needs to be performed:

- Provisioning, with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere).
- Deploy, with [deploy-rs](https://github.com/serokell/deploy-rs).

## Provisioning

> [!NOTE]
> Since the machine you are using is `aarch64-darwin` system, nixos-anywhere emits an error because it requires to be run from a machine with the same architecture, which means `aarch64-linux`.
> To solve this problem it's possible to run nixos-anywhere from a docker container, however for some reasons nixos-anywhere works even with the error 🤷‍♂️.

### First setup

First, run the following commands to use the nixos generators to create the initial machine configuration. This operation needs to be done only when setting up a new host (all the other times you will have the config available in this repository):

1. Start the machine using the NixOS iso.
2. Run `passwd` to set the root password.
3. Get the machine ip with `ifconfig`.
4. If you are not using Parallels (that does this automatically), on the host machine run `echo 'MACHINE_IP osaka' | sudo tee -a /etc/hosts`.
5. Run `lsblk` to find the main partition.
6. Prepare a `disk-config.nix` file using the chosen file system and save it to `/tmp`, set the correct device name for the main disk.
7. Run this command otherwise disko will complain about not having enough disk space available: ```mount -o remount,size=10G,noatime /nix/.rw-store```
8. Format the disk: ```sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disk-config.nix```
9. Check that the filesystem has been formatted and is available with `mount | grep /mnt`
10. Generate the nixos configuration with ```nixos-generate-config --no-filesystems --root /mnt```
11. Copy the `hardware-configuration.nix` and `configuration.nix` files to `systems` folder of this repository.

Now choose if you want to run nixos-anywhere from docker-compose or from MacOS.

### Provision from MacOS

Run the following command:

```
nix run github:nix-community/nixos-anywhere -- --flake '.#osaka' --target-host nixos@osaka
```

### Provision from a container

If you want to run it from a `aarch64-linux` machine, use the docker-compose setup in `provisioners/docker`:
```
# Start the container and open a shell inside it
docker-compose -f provisioners/osaka/docker-compose.yaml run --rm nixos-anywhere

# Setup flakes
mkdir -p /root/.config/nix
echo experimental-features = nix-command flakes > /root/.config/nix/nix.conf

# The current dotfiles/ folder is already mounted inside the container at /home/dotfiles
# Enter the directory and run nixos-anywhere
cd /home/dotfiles
nix run github:nix-community/nixos-anywhere -- --flake '.#osaka' --target-host nixos@osaka
```

### Users and keys setup

Some manual steps are required to setup users and keys.

1. Reboot the machine and remove the nixos iso before restarting the VM.
2. Use 1Password to generate a keypair for the user `root`. The default keys are already in `/etc/ssh` but it's best to to replace them with new ones that are stored in 1Password. This way it's easier to recreate the machine if needed (no need to login, copy the new public key, place it into this configuration and regenerate all the secrets).
  ```
  > op read 'op://Private/Osaka root SSH Key/private key?ssh-format=openssh' \
    | ssh root@osaka 'cat > /etc/ssh/ssh_host_ed25519_key; chmod 600 /etc/ssh/ssh_host_ed25519_key'

  > op read 'op://Private/Osaka root SSH Key/public key' \
    | ssh root@osaka 'cat > /etc/ssh/ssh_host_ed25519_key.pub; chmod 644 /etc/ssh/ssh_host_ed25519_key.pub'
  ```
3. Clean the `~/.ssh/known_hosts` entry of osaka as there's a new key on the machine.
4. Connect to ssh to accept the addition to `known_hosts`
5. Use 1Password to generate a keypair for the user `dario`.
6. Use agenix to set the private key at `/home/dario/.ssh/id_ed25519`.
7. Use 1Password to generate the password for the user `dario`, useful for `sudo`.
8. Run `mkpasswd PASSWORD` to encrypt it.
6. Use agenix to set the user password.
9. Apply the configuration to the machine with ```deploy --hostname osaka .#osaka```
10. Set the in `flake.nix` the user `dario` as the deploy user and set `interactiveSudo` to `true`.

### Parallels tools and folder sharing

To share folders between MacOS and osaka enter the Parallels settings and select the folder to share.
Then set in the machine configuration:
```
nixpkgs.config.allowUnfree = true;
hardware.parallels.enable = true;
hardware.parallels.package = pkgs.prl-tools;

systemd.tmpfiles.rules = [
  "d /mnt/psf 0777 dario users -"
];
```

## Deploying the system configuration

After first provisioning the machine can be updated with `deploy-rs`:

```
deploy --hostname osaka .#osaka
```
