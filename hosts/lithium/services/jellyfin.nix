{
  config,
  lib,
  pkgs,
  ...
}:
let
  svcDomain = "tv.${config.zw.homelab.domain}";
  svcPort = config.zw.servicePorts.tcp.jellyfinHttp;
in
{
  services.caddy.virtualHosts."*.${config.zw.homelab.domain}".extraConfig =
    lib.mkIf config.zw.homelab.reverse-proxy.enable ''
      @tv host ${svcDomain}
      handle @tv {
        reverse_proxy :${toString svcPort}
      }
    '';
  services.jellyfin = {
    enable = true;
    openFirewall = false;
  };
  networking.firewall.allowedTCPPorts = with config.zw.servicePorts.tcp; [
    jellyfinHttp
    jellyfinHttps
  ];
  networking.firewall.allowedUDPPorts = with config.zw.servicePorts.udp; [
    jellyfinSsdp
    jellyfinClientDiscovery
  ];
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
}
