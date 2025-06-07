{ config, pkgs, ... }:
let
  svcDomain = "status.${config.networking.domain}";
  svcPort = config.services.uptime-kuma.settings.PORT;
in
{
  services.caddy.virtualHosts."${svcDomain}".extraConfig = ''
    reverse_proxy :${svcPort}
  '';
  # NOTE: Currently requires some web-interface configuration
  # User must set up an admin account, monitors, and status pages manually.
  services.uptime-kuma = {
    enable = true;
    # NOTE: NixOS Attributes here resolve into these ENV vars:
    # https://github.com/louislam/uptime-kuma/wiki/Environment-Variables
    # settings = {};
  };
}
