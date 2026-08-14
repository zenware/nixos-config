{ config, ... }:
let
  homelabDomain = config.zw.homelab.domain;
  svcDomain = "vault.${homelabDomain}";
  svcPort = config.zw.servicePorts.tcp.vaultwarden;
in
{
  services.caddy.virtualHosts."*.${homelabDomain}".extraConfig = ''
    @vault host ${svcDomain}
    handle @vault {
      reverse_proxy 127.0.0.1:${toString svcPort}
    }
  '';

  services.vaultwarden = {
    enable = true;
    domain = svcDomain;
    backupDir = "/tank/shares/backups/vaultwarden";
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = svcPort;
      SIGNUPS_ALLOWED = false;
      SHOW_PASSWORD_HINT = false;
      ENABLE_WEBSOCKET = true;
    };
  };
}
