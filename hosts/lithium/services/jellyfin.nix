{ config, pkgs, ... }:
let
  svcDomain = "tv.${config.networking.domain}";
in
{
  services.caddy.virtualHosts."${svcDomain}".extraConfig = ''
    reverse_proxy :8096
  '';
  services.jellyfin = {
    enable = true;
    # NOTE: Keeping this open for now, for internal network use.
    # ports 8096 for http and 8920 for https
    openFirewall = true;
  };
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
}
