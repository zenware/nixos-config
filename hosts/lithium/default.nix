{ ... }:
{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./configuration.nix
    ./services/caddy.nix
    ./services/tailscale.nix
    ./services/kanidm.nix
    ./services/jellyfin.nix
    ./services/uptime-kuma.nix
    ./services/file-shares.nix
    ./services/forgejo.nix
    ./services/miniflux
    ./services/calibre-web.nix
    ./services/immich.nix
    ./services/monitoring/grafana.nix
    ./services/palworld.nix
  ];

  zw.llm-agents.enable = true;
}
