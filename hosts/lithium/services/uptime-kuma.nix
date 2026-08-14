{ config, pkgs, ... }:
let
  svcDomain = "status.${config.zw.homelab.domain}";
  svcPort = config.zw.servicePorts.tcp.uptimeKuma;
in
{
  services.caddy.virtualHosts."*.${config.zw.homelab.domain}".extraConfig = ''
    @status host ${svcDomain}
    handle @status {
      reverse_proxy :${toString svcPort}
    }
  '';
  # NOTE: Currently requires some web-interface configuration
  # User must set up an admin account, monitors, and status pages manually.
  services.uptime-kuma = {
    enable = true;
    # NOTE: NixOS Attributes here resolve into these ENV vars:
    # https://github.com/louislam/uptime-kuma/wiki/Environment-Variables
    settings = {
      PORT = toString svcPort;
    };
  };
}
