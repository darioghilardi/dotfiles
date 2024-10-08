# TestVM

TestVM is a virtual machine that was used to quickly iterate on the NAS provisioning. It runs on top of VMWare Fusion.

## Reinstall from scratch

To reinstall the system from scratch follow these steps:

- Setup a VM with 4 SATA disks, two with same size to simulate the NAS OS/Boot/swap storage and other 2 to simulate the storage disks.
- Add a USB device with the nixos minimal image loaded and boot priority to 1
- Start the VM
- Use `passwd` to setup a password for the `nixos` user

Then run the provisioning script from a remote machine:

```
./provisioners/testvm/provision.sh MACHINE_IP
```

Then install nixos within the machine terminal:

```
sudo nixos-install
```
