{
  config,
  lib,
  pkgs,
  ...
}:
let
  homelabDomain = config.zw.homelab.domain;
  svcDomain = "cloud.${homelabDomain}";
  backendPort = config.zw.servicePorts.tcp.nextcloudBackend;
  stateDir = "/tank/services/nextcloud";
in
{
  services.caddy.virtualHosts."*.${homelabDomain}".extraConfig = ''
    @cloud host ${svcDomain}
    handle @cloud {
      reverse_proxy 127.0.0.1:${toString backendPort}
    }
  '';

  systemd.tmpfiles.rules = [
    "d /tank/services 0755 root root -"
    "d ${stateDir} 0750 nextcloud nextcloud -"
  ];

  # Caddy owns the public HTTP/HTTPS ports; Nextcloud's generated Nginx site
  # serves only as a local HTTP backend.
  services.nginx.enable = lib.mkForce true;
  services.nginx.virtualHosts.${svcDomain}.listen = [
    {
      addr = "127.0.0.1";
      port = backendPort;
    }
  ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud34;
    hostName = svcDomain;
    home = stateDir;
    datadir = stateDir;
    https = false;
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminuser = null;
      adminpassFile = null;
    };
    settings = {
      trusted_domains = [ svcDomain ];
      trusted_proxies = [ "127.0.0.1" ];
      overwriteprotocol = "https";
      default_phone_region = "US";
    };
  };
}
