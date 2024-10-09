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
