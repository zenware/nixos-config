{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  certDir = config.security.acme.certs."${config.zw.homelab.domain}".directory;
in
{
  services.nginx.enable = lib.mkForce false;

  # TODO: Add Metrics with Prometheus & Grafana
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      # NOTE: Occasionally specify @latest and update the new versions, and the result hash.
      # Realistically, some sort of automation should be setup for this.
      plugins = [
        # NOTE: v0.2.4+ required for new-format Cloudflare `cfat_`/`cfut_`
        # API tokens (caddy-dns/cloudflare#123); older versions reject them
        # with "API token appears invalid".
        "github.com/mholt/caddy-dynamicdns@v0.0.0-20260711161133-a5890c9df68c"
        "github.com/caddy-dns/cloudflare@v0.2.4"
      ];
      hash = "sha256-eRgpncvTIPwzxEKk5E3sBvA2zp9EULkI5GvbmGGaExA="; # lib.fakeHash;
    };
    # NOTE: Use Staging CA while testing, check `systemctl status caddy`
    # to see if everything is working.
    # acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";
    # environmentFile = config.sops.secrets.cloudflare_env.path;
    # NOTE: DNS provider settings
    # https://caddy.community/t/how-to-use-dns-provider-modules-in-caddy-2/8148
    globalConfig = ''
      # NOTE: DNS-01 for every managed cert. Issuance no longer depends on
      # inbound 80/443 reachability (HTTP-01/TLS-ALPN-01 broke when LE
      # couldn't connect in), and pairs with the wildcard vhost below so only
      # `*.${config.zw.homelab.domain}` ever appears in CT logs.
      acme_dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
      dynamic_dns {
        provider cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
        domains {
          ${config.zw.homelab.domain} @
        }
        dynamic_domains
      }
    '';
  };

  # NOTE: Single wildcard site; each service module appends a `handle` block
  # guarded by a host matcher (extraConfig is `lines`, so definitions merge).
  # The matcher-less handle is the fallback for unmatched subdomains; Caddy
  # evaluates handle blocks in order, so mkAfter keeps it textually last.
  services.caddy.virtualHosts."*.${config.zw.homelab.domain}".extraConfig = lib.mkAfter ''
    handle {
      abort
    }
  '';
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
