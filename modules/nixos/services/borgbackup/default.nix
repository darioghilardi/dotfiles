{
  lib,
  inputs,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.borgbackup;
  user = "borgbackup";
  group = "borgbackup";
in {
  options.${namespace}.services.borgbackup = with types; {
    enable = mkBoolOpt false "Whether or not to enable borg backups.";
    paths = mkOpt (listOf str) [] "The path of the folder to backup.";
    repo = mkOpt str "" "The repo url.";
    passwordFile = mkOpt str "" "Path to the password file.";
  };

  config = mkIf cfg.enable {
    services.borgbackup.jobs = {
      storage = {
        inherit user;

        repo = cfg.repo;
        paths = cfg.paths;

        exclude = [
          ".DS_Store"
          "._*"
        ];

        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat ${cfg.passwordFile}";
        };

        prune.keep = {
          daily = 5;
          weekly = 4;
          monthly = 4;
        };

        environment.BORG_RSH = "ssh -o StrictHostKeyChecking=no -p23 -i /home/${user}/.ssh/id_ed25519";
        compression = "auto,zstd";
        startAt = "*-*-* 3:00:00";
      };
    };

    age.secrets = {
      "borgbackup/password" = {
        file = ../../../../secrets/borgbackup/password.age;
        mode = "700";
        owner = user;
        group = group;
      };
    };

    users = {
      users.borgbackup = {
        isNormalUser = true;
        description = "User for Borg Backup.";
        group = group;
        extraGroups = ["users"];
      };
      groups.borgbackup = {};
    };
  };
}
