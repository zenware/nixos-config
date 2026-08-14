{ config, ... }:
let
  homelabDomain = config.zw.homelab.domain;
  svcDomain = "home.${homelabDomain}";
  svcPort = config.zw.servicePorts.tcp.homeAssistant;
in
{
  services.caddy.virtualHosts."*.${homelabDomain}".extraConfig = ''
    @home host ${svcDomain}
    handle @home {
      reverse_proxy 127.0.0.1:${toString svcPort}
    }
  '';

  systemd.tmpfiles.rules = [
    "d /tank/services 0755 root root -"
    "d /tank/services/home-assistant 0750 hass hass -"
  ];

  services.home-assistant = {
    enable = true;
    configDir = "/tank/services/home-assistant";
    config = {
      homeassistant = {
        name = "Home";
        unit_system = "us_customary";
        time_zone = config.time.timeZone;
      };
      http = {
        server_host = "127.0.0.1";
        server_port = svcPort;
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" ];
      };
    };
  };
}
