{ ... }:
{
  # Private overlay module.
  # Put private services and secret wiring here.

  imports = [
    # Example host private wiring:
    # ../lithium/kanidm-private.nix
    ./sops-secrets
  ];


  # NOTE: zw.homelab.domain is declared in nixos-config
  # (modules/roles/homelab.nix); set your real domain here to keep
  # it out of the public configuration.
  #
  # Use a public domain you own, or claim a unique namespace under
  # home.arpa (RFC 8375) — like Tailscale's per-tailnet names
  # (https://tailscale.com/docs/concepts/tailnet-name) — so nothing
  # collides if home networks are ever bridged. Generate one with:
  #   nix run nixpkgs#rust-petname   # memorable, e.g. "casual-mullet"
  #   openssl rand -hex 2            # short & random, e.g. "8ke2"
  zw.homelab = {
    domain = "casual-mullet.home.arpa";
    reverse-proxy.secretsAreAvailable = true;
    software-forge.enable = true;
    identity-management = true;
  };

  # Example sops-nix wiring:
  # sops.secrets = {
  #   "example/service/api_key" = { sopsFile = ../lithium/secrets.yaml; };
  # };
}
