{ config, pkgs, ... }:
#let
#hostName = config.networking.hostName;
#tailnetName = "tail79151.ts.net";
#svcDomain = "${hostName}.${tailnetName}";
#in
{
  # NOTE: This does require a manual step of creating a tailscale account if
  # you don't already have one, and generating an Auth Key:
  # https://login.tailscale.com/admin/machines/new-linux
  # After enabling this and generating an install script copy the authkey and
  # run: `sudo tailscale up --auth-key=KEY`

  # NOTE: Use Caddy to create and manage SSL Certs for Tailscale
  #services.caddy.virtualHosts."${svcDomain}".extraConfig = ''
  #reverse_proxy :<port>
  #'';
  services.tailscale = {
    enable = true;
    #permitCertUid = "caddy";  # Allow caddy to edit certs
  };
}
