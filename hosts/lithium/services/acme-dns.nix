{ config, ... }:
let
  homelabDomain = config.networking.domain;
  certDir = config.security.acme.certs."${homelabDomain}".directory;
in
{
  # NOTE: This is not currently being used, due to being completely terrible.
  # TODO: Move secrets around if I want to use this again.
  sops.secrets."cloudflare/dns_api_token" = {
    mode = "0440";
    group = config.services.caddy.group;
    restartUnits = [ "caddy.service" "ddclient.service" ];
  };


  # TODO: Consider defining reverse proxy all in one location.
  # All the ports and domains would be visible in one place.
  security.acme = {
    acceptTerms = true;
    defaults = {
      # NOTE: Uncomment the following line for testing, comment for production.
      server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      credentialFiles = {
        CLOUDFLARE_DNS_API_TOKEN_FILE = config.sops.secrets."cloudflare/dns_api_token".path;
      };
      group = config.services.caddy.group;
      #reloadServices = [ "caddy" ];
      email = "admin+acme@${homelabDomain}";  # NOTE: This email is /dev/null;
      #keyType = "ec384";
    };
  };

  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    usev4 = "webv4, webv4=https://cloudflare.com/cdn-cgi/trace, web-skip='ip='";
    username = "token";
    #secretsFile = config.sops.secrets."cloudflare/dns_api_token".path;
    passwordFile = config.sops.secrets."cloudflare/dns_api_token".path;
    zone = homelabDomain;
    domains = [
      homelabDomain
      "*.${homelabDomain}"
      "id.${homelabDomain}"
      "status.${homelabDomain}"
      "grafana.${homelabDomain}"
      "feeds.${homelabDomain}"
      "git.${homelabDomain}"
      "tv.${homelabDomain}"
      "demo.${homelabDomain}"  # Testing to see if the DNS record is set.
    ];
  };

  # NOTE: Issue a single cert /w subdomain wildcard
  # At the expense of individual service security, some public details about
  # attack surface remain slightly more private in https://crt.sh/
  security.acme.certs."${homelabDomain}" = {
    #group = config.services.caddy.group;
    domain = "${homelabDomain}";
    extraDomainNames = [ "*.${homelabDomain}" ];
  };
  # Nginx useACMEHost provides the DNS-01 challenge.
  # security.acme.certs."${homelabDomain}".directory
}
