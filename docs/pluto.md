# Pluto

Pluto is the development virtual machine running on MacOS.

This machine has been setup using [nixos-lima](https://github.com/nixos-lima/nixos-lima).

To create this machine from scratch, two steps needs to be performed:

- Provisioning: installation and first setup.
- Deploy: Rebuild the configuration and update packages using [deploy-rs](https://github.com/serokell/deploy-rs).

## Provisioning

First, [lima](https://lima-vm.io/) must be installed on the system.

Code for provisioning is stored inside `/provisioners/pluto/`. The `yaml` file used by lima has been taken from [here](https://github.com/nixos-lima/nixos-lima-config-sample?tab=readme-ov-file).

Run the first setup with:

```
limactl start --yes provisioners/pluto/pluto.yaml
```

# continue here



After installation run once the rebuild command on the machine:

```
sudo nixos-rebuild switch -I config=/etc/nixos/configuration.nix
```

## Deploying the system configuration

After the first installation, deploy a new configuration using this flake and `deploy-rs`:

```
deploy --hostname MACHINE_IP/HOSTNAME .#saturn
```

## Starting the server

The disks are encrypted so at any restart you need to:

```
ssh root@saturn -p 9999
```

Then decrypt the disks

```
/bin/cryptsetup-askpass

Passphrase for /dev/disk/by-id/ata-CT500MX500SSD1_1834E14E1C41-part2:
# Enter the OS secret key

Passphrase for /dev/disk/by-id/ata-WDC_WD40EFPX-68C6CN0_WD-WX22D24C9VZJ-part1:
# Enter the Storage secret key
```

Now the server can be accessed with:

```
ssh root@saturn -p 2222
```

## Backups

Backups are executed daily with:

- Restic, at 00:00, to Backblaze B2
- BorgBackup, at 3:00, to Hetzner

### BorgBackup

Some useful commands to interact with Borg Backup.

View the list of backups with the follwing command (repository password is required):

```
borg list ssh://u433810@u433810.your-storagebox.de:23/./backups/saturn
```

Mount a backup to `tmp`:

```
borg mount ssh://u433810@u433810.your-storagebox.de:23/./backups/saturn /tmp/backup
```

Then unmount:

```
borg umount /tmp/backup
```

View info about the repository:

```
borg info ssh://u433810@u433810.your-storagebox.de:23/./backups/saturn
```

Delete a backup using the repository url and the archive name:

```
borg delete ssh://u433810@u433810.your-storagebox.de:23/./backups/saturn saturn-storage-2024-11-18T17:49:36
```
