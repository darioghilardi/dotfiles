{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib.extend (
    final: _prev: {
      opts = import ../../lib/opts { lib = final; };
    }
  );
in
{
  flake.modules.nixos.restic =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    with lib.opts;
    let
      cfg = config.my.services.restic;
      hasHealthchecks = cfg.healthchecksUrlFile != "";
    in
    {
      options.my.services.restic = with types; {
        paths = mkOpt (listOf str) [ ] "The path of the folder to backup.";
        envFile = mkOpt str "" "Path to the environment file.";
        repositoryFile = mkOpt str "" "Path to the repository file.";
        passwordFile = mkOpt str "" "Path to the password file.";
        healthchecksUrlFile = mkOpt str "" "Path to file containing the healthchecks.io ping URL.";
      };

      config = {
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
    };
}
