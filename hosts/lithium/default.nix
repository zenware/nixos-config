{ ... }:
{
  imports = [
    ./boot.nix
    ../../modules/nixos/base.nix
    ./hardware.nix
    ./configuration.nix
    ./services/caddy.nix
    ./services/tailscale.nix
    ./services/kanidm.nix
    ./services/jellyfin.nix
    ./services/uptime-kuma.nix
    ./services/file-shares.nix
  ];
}
