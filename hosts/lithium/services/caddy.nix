{ config, pkgs, ... }:
{
  sops.secrets.caddy_env = {
    sopsFile = ../secrets/caddy.env;
    format = "dotenv";
    mode = "0440";
    owner = config.services.caddy.user;
    group = config.services.caddy.group;
    restartUnits = [ "caddy.service" ];
  };
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      # NOTE: Occasionally specify @latest and update the new versions, and the result hash.
      plugins = [
        "github.com/mholt/caddy-dynamicdns@v0.0.0-20250430031602-b846b9e8fb83"
        "github.com/caddy-dns/cloudflare@v0.2.1"
      ];

      # NOTE: Built on 6/4/2025
      hash = "sha256-swskhAr7yFJX+qy0FR54nqJarTOojwhV2Mbk7+fyS0I=";
    };
    # NOTE: Use Staging CA while testing, check `systemctl status caddy`
    # to see if everything is working.
    # acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";

    # TODO: Add Metrics with Prometheus & Grafana
    environmentFile = config.sops.secrets.caddy_env.path;
    globalConfig = ''
      # acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      dynamic_dns {
        provider cloudflare {env.CLOUDFLARE_API_TOKEN}
        domains {
          ${config.networking.domain} @
        }
        dynamic_domains
      }
    '';
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
