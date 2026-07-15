{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib.extend (
    final: _prev: {
      opts = import ../../lib/opts { lib = final; };
    }
  );
in
{
  flake.modules.nixos."nfs" =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    with lib.opts;
    let
      cfg = config.my.services.nfs;
    in
    {
      options.my.services.nfs = with types; {
        exports = mkOption {
          type = listOf (submodule {
            options = {
              path = mkOption {
                type = str;
                description = "Directory to export.";
              };
              clients = mkOption {
                type = str;
                description = "Client spec (e.g. 100.64.0.0/10).";
              };
              options = mkOption {
                type = str;
                default = "rw,sync,no_subtree_check";
                description = "Export options.";
              };
            };
          });
          default = [ ];
          description = "List of NFS exports.";
        };
      };

      config = {
        services.nfs.server = {
          enable = true;
          exports = concatMapStrings (e: "${e.path} ${e.clients}(${e.options})\n") cfg.exports;
        };

        # Only allow NFS through the Tailscale interface
        networking.firewall.interfaces.tailscale0 = {
          allowedTCPPorts = [ 2049 ];
          allowedUDPPorts = [ 2049 ];
        };
      };
    };
}
