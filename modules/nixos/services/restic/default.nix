{
  lib,
  inputs,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.restic;
in {
  options.${namespace}.services.restic = with types; {
    enable = mkBoolOpt false "Whether or not to enable restic backups.";
    paths = mkOpt (listOf str) [] "The path of the folder to backup.";
    envFile = mkOpt str "" "Path to the environment file.";
    repositoryFile = mkOpt str "" "Path to the repository file.";
    passwordFile = mkOpt str "" "Path to the password file.";
  };

  config = mkIf cfg.enable {
    services.restic.backups = {
      storage = {
        # Backups happen daily at midnight
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
      };
    };
  };
}
