# Dotfiles

Nix based configuration for my machines.

## Installation

1. Install Nix using the [Nix Installer](https://github.com/DeterminateSystems/nix-installer).
2. Clone this repository into `~/dotfiles` (on MacOS install the command line tools when prompted, as git is not installed on a fresh MacOS installation).
3. Run `nix build` for the machine to provision.
4. Run `darwin-rebuild switch --flake .`
5. After the first run just run the aliased commands to switch the configuration.

## Secrets

Secrets are encrypted using [agenix](https://github.com/ryantm/agenix).

To create a new secret, add first an entry to `secrets/secrets.nix`, declaring which public key should be used to encrypt the secret. Then run:

```
RULES=secrets/secrets.nix agenix -e NEW_SECRET.age && mv NEW_SECRET.age secrets/
```

An editor will open, write the secrets content then save and quit.

Declare the secret in the configuration using:

```
age.secrets = {
  secret = {file = PATH_TO_SECRETS/SECRET.age;};
};
```

Use the secret with:

```
config.age.secrets.SECRET.path;
```

## Saturn

To deploy a new configuration run:

```
deploy --hostname MACHINE_IP/HOSTNAME .#saturn
```

The `saturn` machine was initially provisioned using `nixos-anywhere`. 
In the unlikely case it needs to be provisioned again, the following command can be used:

```
nix run github:nix-community/nixos-anywhere -- --debug --build-on-remote --flake .#saturn root@MACHINE_IP
```


### Credits

- [Snowfall lib](https://snowfall.org/)
- [Jake Hamilton config](https://github.com/jakehamilton/config/blob/c68c9c41963b4a4937eb82da190f9422f37cf203/modules/home/tools/git/default.nix)
