let
  dariobook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlcsiLTBnj6tGb5P49Zcg5svvT6qIDLbfar7ac8YLwi";
  saturn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK3skuhXYXoKD2E8x8wvPlbRmia+uAM9JkX3KYTHeQ4Y";
in {
  "tailscale-key.age".publicKeys = [dariobook saturn];
  "restic/repo.age".publicKeys = [dariobook saturn];
  "restic/password.age".publicKeys = [dariobook saturn];
  "restic/env.age".publicKeys = [dariobook saturn];
}
