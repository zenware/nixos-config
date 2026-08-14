{ config, ... }:
let
  homelabDomain = config.zw.homelab.domain;
  svcDomain = "sync.${homelabDomain}";
  guiPort = config.zw.servicePorts.tcp.syncthingGui;
  dataDir = "/tank/shares/syncthing";
in
{
  services.caddy.virtualHosts."*.${homelabDomain}".extraConfig = ''
    @sync host ${svcDomain}
    handle @sync {
      reverse_proxy 127.0.0.1:${toString guiPort}
    }
  '';

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 syncthing syncthing -"
  ];

  services.syncthing = {
    enable = true;
    inherit dataDir;
    guiAddress = "127.0.0.1:${toString guiPort}";
    openDefaultPorts = false;
    settings = {
      gui.user = "admin";
      options.urAccepted = -1;
    };
  };

  networking.firewall.allowedTCPPorts = [ config.zw.servicePorts.tcp.syncthingTransfer ];
  networking.firewall.allowedUDPPorts = with config.zw.servicePorts.udp; [
    syncthingDiscovery
    syncthingTransfer
  ];
}
