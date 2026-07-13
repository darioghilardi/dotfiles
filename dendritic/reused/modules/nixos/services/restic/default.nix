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
  cfg = config.${namespace}.services.restic;
  hasHealthchecks = cfg.healthchecksUrlFile != "";
in {
  options.${namespace}.services.restic = with types; {
    enable = mkBoolOpt false "Whether or not to enable restic backups.";
    paths = mkOpt (listOf str) [] "The path of the folder to backup.";
    envFile = mkOpt str "" "Path to the environment file.";
    repositoryFile = mkOpt str "" "Path to the repository file.";
    passwordFile = mkOpt str "" "Path to the password file.";
    healthchecksUrlFile = mkOpt str "" "Path to file containing the healthchecks.io ping URL.";
  };

  config = mkIf cfg.enable {
    services.restic.backups = {
      storage = {
        initialize = true;
        exclude = [
          ".DS_Store"
          "._*"
        ];

        environmentFile = cfg.envFile;
        repositoryFile = cfg.repositoryFile;
        passwordFile = cfg.passwordFile;

        paths = cfg.paths;

        pruneOpts = [
          "--keep-daily 5"
          "--keep-weekly 4"
          "--keep-monthly 4"
        ];

        backupPrepareCommand = optionalString hasHealthchecks ''
          ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "$(cat ${cfg.healthchecksUrlFile})/start" || true
        '';
      };
    };

    systemd.services."restic-backups-storage" = mkIf hasHealthchecks {
      serviceConfig.ExecStartPost = pkgs.writeShellScript "restic-notify-success" ''
        ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "$(cat ${cfg.healthchecksUrlFile})"
      '';
      unitConfig.OnFailure = "restic-backups-storage-notify-fail.service";
    };

    systemd.services."restic-backups-storage-notify-fail" = mkIf hasHealthchecks {
      description = "Notify healthchecks.io of restic failure";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "restic-notify-fail" ''
          ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "$(cat ${cfg.healthchecksUrlFile})/fail"
        '';
      };
    };
  };
}
