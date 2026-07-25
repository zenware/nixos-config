{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  svcDomain = "grafana.${config.zw.homelab.domain}";
  svcPort = config.services.grafana.settings.server.http_port;
in
{
  services.caddy.virtualHosts."*.${config.zw.homelab.domain}".extraConfig = ''
    @grafana host ${svcDomain}
    handle @grafana {
      reverse_proxy :${toString svcPort}
    }
  '';

  services.grafana = {
    enable = true;
    settings = {
      # NOTE: security.secret_key is supplied via sops in nixos-secrets
      # (grafana/secret_key); the nixpkgs default here is overridden there.
      security.secret_key = lib.mkDefault "SW2YcwTIb9zpOOhoPsMm";
      server = {
        http_addr = "127.0.0.1";
        http_port = 3001;
        enforce_domain = true;
        enable_gzip = true;
        domain = svcDomain;
      };
      analytics.reporting_enabled = false; # NOTE: Disable Telemetry
    };
  };
}
