{ ... }:
{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./configuration.nix
    ./service-ports.nix
    ./services/caddy.nix
    ./services/tailscale.nix
    ./services/kanidm.nix
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
    ./services/syncthing.nix
    ./services/adguardhome.nix
    ./services/monitoring/grafana.nix
    ./services/palworld.nix
  ];

  zw.llm-agents.enable = true;
}
