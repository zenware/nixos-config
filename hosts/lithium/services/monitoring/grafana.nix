{ inputs, config, pkgs, ... }:
let
  svcDomain = "grafana.${config.networking.domain}";
  svcPort = config.services.grafana.settings.server.http_port;
in
{
  services.caddy.virtualHosts."${svcDomain}".extraConfig = ''
    reverse_proxy :${toString svcPort}
  '';

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3001;
        enforce_domain = true;
        enable_gzip = true;
        domain = svcDomain;
      };
      analytics.reporting_enabled = false;  # NOTE: Disable Telemetry
    };
  };
}
