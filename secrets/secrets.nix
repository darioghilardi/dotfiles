let
  dariobook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlcsiLTBnj6tGb5P49Zcg5svvT6qIDLbfar7ac8YLwi";
  saturn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWDay3hvpu0QsKPn2Omcintb63KqvWn1gaqrXXJzU3m";
in {
  "tailscale-key.age".publicKeys = [dariobook saturn];
}
