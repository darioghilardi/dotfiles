{
  config,
  pkgs,
  ...
}: {
  age.secrets = {
    dario-ssh-key = {
      file = ../../../secrets/osaka/dario-ssh-key.age;
      path = "/home/dario/.ssh/id_ed25519";
      mode = "600";
      owner = "dario";
      group = "users";
    };
    dario-password.file = ../../../secrets/osaka/dario-password.age;
  };
}
