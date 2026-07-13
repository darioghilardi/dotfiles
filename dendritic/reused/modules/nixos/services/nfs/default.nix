{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.nfs;
in {
  options.dariodots.services.nfs = with types; {
    enable = mkBoolOpt false "Whether or not to enable NFS server.";
    exports = mkOption {
      type = listOf (submodule {
        options = {
          path = mkOption {type = str; description = "Directory to export.";};
          clients = mkOption {type = str; description = "Client spec (e.g. 100.64.0.0/10).";};
          options = mkOption {type = str; default = "rw,sync,no_subtree_check"; description = "Export options.";};
        };
      });
      default = [];
      description = "List of NFS exports.";
    };
  };

  config = mkIf cfg.enable {
    services.nfs.server = {
      enable = true;
      exports = concatMapStrings (e: "${e.path} ${e.clients}(${e.options})\n") cfg.exports;
    };

    # Only allow NFS through the Tailscale interface
    networking.firewall.interfaces.tailscale0 = {
      allowedTCPPorts = [2049];
      allowedUDPPorts = [2049];
    };
  };
}
