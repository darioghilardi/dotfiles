{
  lib,
  pkgs,
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
  hasHealthchecks = cfg.healthchecksUrlFile != "";
in {
  options.${namespace}.services.borgbackup = with types; {
    enable = mkBoolOpt false "Whether or not to enable borg backups.";
    paths = mkOpt (listOf str) [] "The path of the folder to backup.";
    repo = mkOpt str "" "The repo url.";
    passwordFile = mkOpt str "" "Path to the password file.";
    healthchecksUrlFile = mkOpt str "" "Path to file containing the healthchecks.io ping URL.";
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

        environment.BORG_RSH = "ssh -o StrictHostKeyChecking=no -o KexAlgorithms=mlkem768x25519-sha256,sntrup761x25519-sha512@openssh.com,curve25519-sha256@libssh.org -p23 -i /home/${user}/.ssh/id_ed25519";
        compression = "auto,zstd";
        startAt = "*-*-* 3:00:00";

        preHook = optionalString hasHealthchecks ''
          ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "$(cat ${cfg.healthchecksUrlFile})/start" || true
        '';
        postHook = optionalString hasHealthchecks ''
          ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "$(cat ${cfg.healthchecksUrlFile})" || true
        '';
      };
    };

    systemd.services."borgbackup-job-storage" = mkIf hasHealthchecks {
      unitConfig.OnFailure = "borgbackup-job-storage-notify-fail.service";
    };

    systemd.services."borgbackup-job-storage-notify-fail" = mkIf hasHealthchecks {
      description = "Notify healthchecks.io of borgbackup failure";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "borgbackup-notify-fail" ''
          ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "$(cat ${cfg.healthchecksUrlFile})/fail"
        '';
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
