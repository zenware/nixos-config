{ ... }:
{
  imports = [
    ./hardware.nix
    ./configuration.nix
    ./semi-secret-vars.nix
    ./services/caddy.nix
    ./services/kanidm.nix
    ./services/jellyfin.nix
    ./services/uptime-kuma.nix
  ];
}
