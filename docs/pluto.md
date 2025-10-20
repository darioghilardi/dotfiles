# Pluto

Pluto is the development virtual machine running on MacOS, based on [lima](https://lima-vm.io/) and [nixos-lima](https://github.com/nixos-lima/nixos-lima).

To create this machine from scratch, two steps needs to be performed:

- Provisioning
- Deploy: Rebuild the configuration and update packages using [deploy-rs](https://github.com/serokell/deploy-rs).

## Provisioning

First, [lima](https://lima-vm.io/) must be installed on your system.

Code for provisioning is stored inside `/provisioners/pluto/`. The `yaml` file used by lima has been taken from [here](https://github.com/nixos-lima/nixos-lima-config-sample?tab=readme-ov-file) and slightly edited.

Run the setup with:

```
limactl start --yes provisioners/pluto/pluto.yaml
```

This will create the NixOS VM, that can be accessed with:

```
limactl shell pluto
```

## Deploying the system configuration

Lima forwards `localhost:50006` to the 22 port on the VM.

This port is available on the host system and forwards to the VM.
Set the port in `flake.nix`, then deploy a new configuration using this flake and `deploy-rs`:

```
deploy --hostname 127.0.0.1 .#pluto
```

Then restart the instance to have fish as the default shell.
The machine port will change, update it in the `flake.nix` file.

```
limactl shell pluto -- mkdir -p /home/dario.linux/.config
limactl shell pluto -- nix run home-manager/master -- init --switch
```
