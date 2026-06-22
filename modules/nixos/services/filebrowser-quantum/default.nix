{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.filebrowser-quantum;

  stateDir = "/var/lib/filebrowser-quantum";
  cacheDir = "/var/cache/filebrowser-quantum";

  settings = {
    server = {
      port = cfg.port;
      listen = "0.0.0.0"; # firewall restricts exposure to tailscale0 below
      database = "${stateDir}/database.db";
      cacheDir = cacheDir;
      sources = [{path = cfg.root;}];
    };
    auth = {
      adminUsername = "admin";
      methods.password.enabled = true;
    };
  };

  configFile = (pkgs.formats.yaml {}).generate "filebrowser-quantum.yaml" settings;

  # Quantum applies FILEBROWSER_ADMIN_PASSWORD when it first creates the admin
  # user. Inject it via env (visible only in the process environment, never in
  # the world-readable nix store config nor in `ps` args).
  startScript = pkgs.writeShellScript "filebrowser-quantum-start" ''
    set -euo pipefail
    ${optionalString (cfg.passwordFile != null) ''
      export FILEBROWSER_ADMIN_PASSWORD="$(cat ${toString cfg.passwordFile})"
    ''}
    exec ${getExe cfg.package}
  '';
in {
  options.${namespace}.services.filebrowser-quantum = with types; {
    enable = mkBoolOpt false "Whether or not to enable the FileBrowser Quantum web UI (Tailscale-only).";
    package = mkOpt package pkgs.filebrowser-quantum "The filebrowser-quantum package to use.";
    port = mkOpt port 8081 "Port FileBrowser Quantum listens on.";
    root = mkOpt path "/home/storage" "Directory served by FileBrowser Quantum.";
    user = mkOpt str "filebrowser" "User account under which FileBrowser Quantum runs.";
    group = mkOpt str "filebrowser" "Group under which FileBrowser Quantum runs.";
    passwordFile = mkOpt (nullOr path) null "Path to a file holding the admin password, injected as FILEBROWSER_ADMIN_PASSWORD on first run.";
  };

  config = mkIf cfg.enable {
    systemd.services.filebrowser-quantum = {
      description = "FileBrowser Quantum";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${startScript}";
        User = cfg.user;
        Group = cfg.group;
        Environment = ["FILEBROWSER_CONFIG=${configFile}"];
        StateDirectory = "filebrowser-quantum";
        CacheDirectory = "filebrowser-quantum";
        WorkingDirectory = stateDir;
        Restart = "on-failure";
        UMask = "0077";

        # Hardening (mirrors the upstream filebrowser unit).
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        LockPersonality = true;
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
        DevicePolicy = "closed";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };

    # Only reachable over the Tailscale interface, never the public internet.
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [cfg.port];
  };
}
