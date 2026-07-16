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

Note that the script will configure a static IP for the machine which is `192.168.1.102`. Remember to change it if needed. Also remember that the private key of the system always change on new installations (this in turn requires secrets to be encrypted again).

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

### Deploy fails with "Could not acquire lock" / activation exit status 11

If a deploy fails during activation with `Could not acquire lock` and
deploy-rs rolls back (`exit status: 11`), the cause is usually **not** a bad
config — retrying the same deploy will fail identically. The real failure mode
seen on saturn: `switch-to-configuration` tried to **reload
`dbus-broker.service`** (the system D-Bus bus), the reload timed out, and the
bus was killed and never came back. With the system bus dead:

- every dbus/varlink client breaks — logind can no longer create sessions
  (`Transport endpoint is not connected`, `io.systemd.Login.CreateSession
  failed`);
- the `switch-to-configuration` process spins at ~100% CPU retrying the dead
  bus forever, holding the Nix **system profile lock** — which is what makes
  every subsequent deploy fail with `Could not acquire lock`.

This can be triggered by systemd/dbus changes across a channel bump (it hit us
on the 26.05 / systemd 260 upgrade).

**Recover in place (no reboot — a reboot would strand saturn at the LUKS
prompt, see the boot section below).** Over SSH as root:

```
# 1. Find and kill the stuck switch + orphaned deploy processes (this frees
#    the profile lock). Confirm none remain afterwards.
ps aux | grep -E "switch-to-configuration|deploy-rs|nix-env" | grep -v grep
kill -KILL <PIDs>

# 2. Confirm the system bus is dead, then restart it.
systemctl is-active dbus-broker.service          # -> inactive
systemctl start dbus-broker.service
busctl --system list | head                       # should now round-trip

# 3. Reconnect the bus clients and PID 1's managers.
systemctl restart systemd-logind.service
systemctl daemon-reexec
loginctl list-sessions                            # should list sessions, no errors

# 4. Verify, then redeploy from the workstation.
systemctl is-system-running                       # running
systemctl --failed                                # 0 failed units
```

A clean redeploy afterwards will *start* `dbus-broker.service` (rather than
reload a live one) and complete normally. Because this recovery depends on SSH
staying reachable while the bus is down, it is fragile on this host until the
initrd remote-unlock migration below is done.

## Starting the server

The disks are encrypted so at any restart you need to find the ip address of the server, as likely it's given through dhcp:

```
nix run nixpkgs#nmap -- -p 9999 --open -Pn 192.168.1.0/24
```

Then connect:

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

## Boot / initrd (LUKS + ZFS)

### Current state: forced scripted (classic) initrd

Saturn boots with the **classic scripted initrd**, forced on in
`hosts/saturn/boot-configuration.nix`:

```nix
boot.initrd.systemd.enable = lib.mkForce false;
```

This is required because `nixos-26.05` flipped the default to **systemd
stage-1 initrd**, which does *not* support the scripted-initrd features this
host's boot depends on:

- `boot.initrd.preLVMCommands` — the `sleep 1` device-settle workaround.
- `boot.initrd.postDeviceCommands` — the `zpool import -a -f -d /dev/mapper`
  that speeds up pool import.
- `boot.initrd.luks.devices.*.preLVM` — the ordering flag on the four LUKS
  containers (`os_1`, `os_2`, `storage_1`, `storage_2`).

Without the force, the config fails to evaluate with `systemd stage 1 does not
support ...` assertions. Forcing scripted initrd keeps the existing
LUKS-unlock + ZFS-import boot behavior unchanged.

### Migration required for 26.11

**Scripted initrd is deprecated and removed in `nixos-26.11`.** Before
upgrading saturn past 26.05, the boot must be migrated to systemd stage-1
initrd. Do this on the `testvm` provisioner first — a broken initrd on saturn
locks the box out until you have physical console access.

Steps (verify details against the NixOS 26.11 release notes):

1. **Remove the force.** Delete `boot.initrd.systemd.enable = lib.mkForce
   false;` so systemd stage-1 initrd (the new default) is used.
2. **Drop the manual ZFS import.** Under systemd initrd, pools are imported by
   auto-generated `zfs-import-<pool>.service` units from `boot.zfs.extraPools`
   and the `fileSystems` entries — so `boot.initrd.postDeviceCommands` (the
   `zpool import`) can be removed. If a forced import is still needed, express
   it as a `boot.initrd.systemd.services.<name>` unit instead.
3. **Drop the settle workaround.** Remove `boot.initrd.preLVMCommands` (the
   `sleep 1`); systemd initrd orders devices via units. If a wait is still
   needed, model it as a unit dependency rather than a sleep.
4. **Clean up the LUKS devices.** Remove the now-meaningless `preLVM = true`
   from each `boot.initrd.luks.devices.<name>` (there is no LVM here). The
   device declarations themselves stay; systemd initrd unlocks them via the
   generated `systemd-cryptsetup@` units.
5. **Fix remote unlock (finally).** `boot.initrd.network.ssh` still works under
   systemd initrd, but the passphrase prompt is no longer `cryptsetup-askpass`.
   After SSHing into the initrd (see "Starting the server"), unlock with:

   ```
   systemd-tty-ask-password-agent --query
   ```

   This replaces the long-broken `postCommands = "/bin/cryptsetup-askpass"`
   (currently commented out with a FIXME). Update the "Starting the server"
   section above once this lands.
6. **Set the new ZFS default.** Add `boot.zfs.forceImportRoot = false;` — it is
   the recommended value and becomes the default in 26.11.

Apply the same changes to the provisioner template
(`provisioners/saturn/configuration.tpl.nix`), which mirrors this boot config
for fresh installs.

## Backups

Backups are executed daily with:

- Restic, at 00:00, to Backblaze B2
- BorgBackup, at 3:00, to Hetzner

### BorgBackup

The SSH connection uses post-quantum key exchange (`mlkem768x25519-sha256`) to avoid warnings from Hetzner's newer OpenSSH.

#### File permissions and ACLs

Borgbackup runs as the `borgbackup` user but files in `/home/storage` may be owned by other users (e.g. written via NFS as `dario`). POSIX ACLs grant borgbackup read access without changing file ownership.

The ZFS dataset must have ACL support enabled. This is a one-time operation that persists in pool metadata:

```
zfs set acltype=posixacl xattr=sa zpool_storage/storage
```

The NixOS config then runs `setfacl -R -m u:borgbackup:rX,d:u:borgbackup:rX /home/storage` automatically before each backup via `borgbackup-job-storage-acl.service`. The `d:` prefix sets a default ACL so newly created files inherit the permission.

Job status is monitored via healthchecks.io. The ping URL is stored as an agenix secret at `secrets/healthchecks/borgbackup.age`. The job pings `/start` before running and the base URL on success. On failure, systemd triggers a one-shot service that pings `/fail`.

To trigger the job manually:

```
systemctl start borgbackup-job-storage
```

To follow the logs:

```
journalctl -u borgbackup-job-storage -f
```

To test the failure notification:

```
systemctl start borgbackup-job-storage-notify-fail
```

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
