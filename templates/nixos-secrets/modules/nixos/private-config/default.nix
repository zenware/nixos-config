{ config, lib, ... }:
{
  # Private overlay module.
  # Put private services and secret wiring here.

  imports = [
    # Example host private wiring:
    # ../lithium/kanidm-private.nix
    ./sops-secrets
  ];

  # Example sops-nix wiring:
  # sops.secrets = {
  #   "example/service/api_key" = { sopsFile = ../lithium/secrets.yaml; };
  # };
}
