{ inputs, ... }:
{
  imports = [
    ../../modules/nixos/base.nix
    inputs.sops-nix.nixosModules.sops
    ./hardware.nix
    ./configuration.nix
    ./semi-secret-vars.nix
    ./services/caddy.nix
    ./services/tailscale.nix
    ./services/kanidm.nix
    ./services/jellyfin.nix
    ./services/uptime-kuma.nix
    ./services/file-shares.nix
  ];
}
