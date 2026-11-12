{ ... }:
{
  flake.modules.nixos.home-assistant =
    { config, ... }:
    let
      port = 8123;
      cfgDir = config.services.home-assistant.configDir;
    in
    {
      services.home-assistant = {
        enable = true;

        # "matter" controls Matter devices locally through matter-server.
        # Tapo plugs with TPAP firmware do not work with "tplink"
        # (python-kasa has no TPAP support), so use Matter for them.
        extraComponents = [
          "default_config"
          "met"
          "esphome"
          "isal"
          "matter"
          "tplink"
        ];

        config = {
          default_config = { };

          homeassistant = {
            time_zone = config.time.timeZone;
            unit_system = "metric";
          };

          http.server_port = port;

          # Keep automations, scripts and scenes editable from the UI.
          "automation ui" = "!include automations.yaml";
          "script ui" = "!include scripts.yaml";
          "scene ui" = "!include scenes.yaml";
        };

        # The module default is false. Keep it false: the port must not
        # open on the LAN or the public interface.
        openFirewall = false;
      };

      # Matter controller. Home Assistant connects to it at
      # ws://localhost:5580/ws. The websocket port stays closed in the
      # firewall (openFirewall = false), so only local clients reach it.
      # The host must open the Matter UDP ports on its LAN interface.
      services.matter-server = {
        enable = true;
        openFirewall = false;
      };

      # Home Assistant refuses to start if an included file is missing.
      systemd.tmpfiles.rules = [
        "f ${cfgDir}/automations.yaml 0644 hass hass"
        "f ${cfgDir}/scripts.yaml 0644 hass hass"
        "f ${cfgDir}/scenes.yaml 0644 hass hass"
      ];

      # Only reachable over the Tailscale interface, never the LAN or the
      # public internet.
      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ port ];
    };
}
