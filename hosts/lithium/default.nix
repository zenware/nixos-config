{ ... }:
{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./configuration.nix
    ./service-ports.nix
    # TODO: Wrap Caddy in an option module so we can use it better with and without cloudflare secrets.
    #./services/caddy.nix
    ./services/tailscale.nix
    # TODO: Fix real issues with kanidm
    #./services/kanidm.nix
    ./services/jellyfin.nix
    ./services/uptime-kuma.nix
    ./services/file-shares.nix
    ./services/forgejo.nix
    ./services/forgejo-runner.nix
    ./services/miniflux
    ./services/calibre-web.nix
    ./services/immich.nix
    ./services/home-assistant.nix
    ./services/paperless.nix
    ./services/vaultwarden.nix
    ./services/nextcloud.nix
    # TODO: Get Syncthing working someday maybe?
    #./services/syncthing.nix
    ./services/adguardhome.nix
    ./services/monitoring/grafana.nix
    ./services/palworld.nix
  ];

  zw.llm-agents.enable = true;
}
