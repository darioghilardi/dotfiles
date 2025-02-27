# Saturn

Saturn is the NAS server.

The configuration of this machine is splitted in two steps:

- Installation and first setup are done using the script into the `provisioners` folder, which is intended to run only once. After the installation the machine has root openssh access available.
- Following configurations are deployed with [deploy-rs](https://github.com/serokell/deploy-rs), from the current flake.

## Reinstall from scratch

To reinstall the system from scratch, prepare a USB key with the NixOS minimal installer. Boot the system from the USB key *in UEFI mode* (there will be two entries in the boot options, select the UEFI entry).

Then run the provisioning script from a remote machine:

```
./provisioners/saturn/provision.sh MACHINE_IP
```

Note that the script will configure a static IP for the machine which is `192.168.8.102`. Remember to change it if needed. Also remember that the private key of the system always change on new installations (this in turn requires secrets to be encrypted again).

Then install nixos within the machine terminal:

```
sudo nixos-install
```

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
