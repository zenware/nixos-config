{ config, lib, ... }:
let
  homelabDomain = config.zw.homelab.domain;
  svcDomain = "adguard.${homelabDomain}";
  webPort = config.zw.servicePorts.tcp.adguardHome;
  dnsPort = config.zw.servicePorts.tcp.adguardDns;
in
{

  config = {
    # TODO: Might be best to define some kind of function for this...
    services.caddy.virtualHosts."*.${homelabDomain}".extraConfig =
      lib.mkIf config.zw.homelab.reverse-proxy.enable ''
        @adguard host ${svcDomain}
        handle @adguard {
          reverse_proxy 127.0.0.1:${toString webPort}
        }
      '';

    services.adguardhome = {
      enable = true;
      port = webPort;
      settings = {
        http.address = "127.0.0.1";
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
  };
}
