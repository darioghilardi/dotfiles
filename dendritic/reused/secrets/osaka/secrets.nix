let
  dariobook = builtins.readFile ../../keys/dariobook.pub;
  osaka-root = builtins.readFile ../../keys/osaka-root.pub;
  osaka-dario = builtins.readFile ../../keys/osaka-dario.pub;
in {
  "dario-ssh-key.age".publicKeys = [dariobook osaka-root];
  "dario-password.age".publicKeys = [dariobook osaka-root];
}
