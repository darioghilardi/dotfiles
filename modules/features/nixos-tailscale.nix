{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib.extend (
    final: _prev: {
      opts = import ../../lib/opts { lib = final; };
    }
  );
in
{
  flake.modules.nixos.tailscale =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    with lib.opts;
    let
      cfg = config.my.services.tailscale;
    in
    {
      options.my.services.tailscale = with types; {
        autoconnect = {
          enable = mkBoolOpt false "Whether or not to enable automatic connection to Tailscale";
          key = mkOpt str "" "The path to the authentication key to use";
        };
      };

      config = {
        assertions = [
          {
            assertion = cfg.autoconnect.enable -> cfg.autoconnect.key != "";
            message = "my.services.tailscale.autoconnect.key must be set";
          }
        ];

        environment.systemPackages = with pkgs; [ tailscale ];

        services.tailscale = enabled;

        networking = {
          firewall = {
            trustedInterfaces = [ config.services.tailscale.interfaceName ];

            allowedUDPPorts = [ config.services.tailscale.port ];

            # Strict reverse path filtering breaks Tailscale exit node use and some subnet routing setups.
            checkReversePath = "loose";
          };

          networkmanager.unmanaged = [ "tailscale0" ];
        };

        systemd.services.tailscale-autoconnect = mkIf cfg.autoconnect.enable {
          description = "Automatic connection to Tailscale";

          # Make sure tailscale is running before trying to connect to tailscale
          after = [
            "network-pre.target"
            "tailscale.service"
          ];
          wants = [
            "network-pre.target"
            "tailscale.service"
          ];
          wantedBy = [ "multi-user.target" ];

          # Set this service as a oneshot job
          serviceConfig.Type = "oneshot";

          # Have the job run this shell script
          script = with pkgs; ''
            # Wait for tailscaled to settle
            sleep 2

            # Check if we are already authenticated to tailscale
            status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
            if [ $status = "Running" ]; then # if so, then do nothing
              exit 0
            fi

            # Otherwise authenticate with tailscale
            # ${tailscale}/bin/tailscale up -authkey file:${cfg.autoconnect.key}
          '';
        };
      };
    };
}
