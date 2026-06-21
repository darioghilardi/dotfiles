{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.filebrowser;

  fb = getExe config.services.filebrowser.package;
  db = config.services.filebrowser.settings.database;

  # Seed/update the admin account from a secret before the server starts, so
  # FileBrowser never generates a random first-run password. Idempotent: runs
  # on every start and reconciles the password with the secret file.
  setupAdmin = pkgs.writeShellScript "filebrowser-init-admin" ''
    set -euo pipefail
    pw="$(cat ${toString cfg.passwordFile})"
    if [ ! -f ${db} ]; then
      ${fb} -d ${db} config init
      ${fb} -d ${db} users add admin "$pw" --perm.admin
    elif ${fb} -d ${db} users ls | grep -qw admin; then
      ${fb} -d ${db} users update admin --password "$pw"
    else
      ${fb} -d ${db} users add admin "$pw" --perm.admin
    fi
  '';
in {
  options.${namespace}.services.filebrowser = with types; {
    enable = mkBoolOpt false "Whether or not to enable the FileBrowser web UI (Tailscale-only).";
    port = mkOpt port 8080 "Port FileBrowser listens on.";
    root = mkOpt path "/home/storage" "Directory served by FileBrowser.";
    user = mkOpt str "filebrowser" "User account under which FileBrowser runs.";
    group = mkOpt str "filebrowser" "Group under which FileBrowser runs.";
    passwordFile = mkOpt (nullOr path) null "Path to a file holding the admin password. When set, the 'admin' user is created/updated to match it on each start.";
  };

  config = mkIf cfg.enable {
    services.filebrowser = {
      enable = true;
      inherit (cfg) user group;

      # Never open the firewall globally; access is restricted to Tailscale below.
      openFirewall = false;

      settings = {
        # Listen on all interfaces, but the firewall only exposes the port on tailscale0.
        address = "0.0.0.0";
        inherit (cfg) port root;
      };
    };

    # Seed the admin password from the secret before the server boots.
    systemd.services.filebrowser.serviceConfig.ExecStartPre =
      mkIf (cfg.passwordFile != null) ["${setupAdmin}"];

    # The upstream module force-creates the served root as 0700 owned by the
    # service user. Keep it world-readable (0755) and aligned with the
    # configured user/group so it does not clobber an externally-managed dir.
    systemd.tmpfiles.settings.filebrowser.${cfg.root}.d = mkForce {
      inherit (cfg) user group;
      mode = "0755";
    };

    # Only reachable over the Tailscale interface, never the public internet.
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [cfg.port];
  };
}
