{ config, ... }:
let
  homelabDomain = config.zw.homelab.domain;
  svcDomain = "adguard.${homelabDomain}";
  webPort = config.zw.servicePorts.tcp.adguardHome;
  dnsPort = config.zw.servicePorts.tcp.adguardDns;
in
{
  services.caddy.virtualHosts."*.${homelabDomain}".extraConfig = ''
    @adguard host ${svcDomain}
    handle @adguard {
      reverse_proxy 127.0.0.1:${toString webPort}
    }
  '';

  services.adguardhome = {
    enable = true;
    host = "127.0.0.1";
    port = webPort;
    settings = {
      dns = {
        bind_hosts = [ "0.0.0.0" ];
        port = dnsPort;
        bootstrap_dns = [
          "1.1.1.1"
          "9.9.9.9"
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ dnsPort ];
  networking.firewall.allowedUDPPorts = [ dnsPort ];
}
