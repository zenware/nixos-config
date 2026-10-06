{ ... }:
{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./configuration.nix
    ./service-ports.nix
    ./services/tailscale.nix
    ./services/file-shares.nix
    ./services/monitoring/grafana.nix
    # TODO: Fix real issues with kanidm
    ./services/kanidm.nix
    ./services/caddy.nix
    ./services/adguardhome.nix
    ./services/vaultwarden.nix
    ./services/uptime-kuma.nix
    ./services/miniflux
    ./services/forgejo
    ./services/paperless.nix
    ./services/home-assistant.nix
    ./services/jellyfin.nix
    ./services/immich.nix
    ./services/calibre-web.nix
    #./services/nextcloud.nix
    # TODO: Get Syncthing working someday maybe?
    #./services/syncthing.nix
    # Game Servers:
    ./services/palworld.nix
  ];

  zw.game-servers = {
    enable = true;
    palworld.enable = false; # Palworld/Steam is too flaky to build all the time.
  };
  zw.homelab.identity-management.enable = false; # Run a Kanidm identity service
  zw.homelab.reverse-proxy.enable = true;
  zw.llm-agents.enable = true;
}
