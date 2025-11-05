{
  config,
  pkgs,
  ...
}: {
  nix.settings.trusted-users = ["@wheel"];
  security.sudo.enable = true;

  # Required to be able to set new passwords through nix.
  users.mutableUsers = false;

  users.users.dario = {
    home = "/home/dario";
    isNormalUser = true;
    group = "users";
    shell = pkgs.fish;
    extraGroups = ["wheel" "docker"];
    hashedPasswordFile = config.age.secrets.dario-password.path;
    openssh.authorizedKeys.keyFiles = [../../../keys/dariobook.pub];
  };

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [../../../keys/dariobook.pub];
  };
}
