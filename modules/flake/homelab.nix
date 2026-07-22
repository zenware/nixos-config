{
  # NOTE: Every module declared under flake.modules.nixos is imported into
  # every host built with mkSystem (see ./lib.nix and ../../lib/default.nix),
  # including the hosts assembled by the private `nixos-secrets` flake.
  # Modules here must therefore be safe-by-default: declare options, gate any
  # config behind them, and keep real (private) values out — those get set in
  # `nixos-secrets`.
  flake.modules.nixos.homelab =
    { config, lib, ... }:
    {
      options.zw.homelab = {
        # https://datatracker.ietf.org/doc/html/rfc8375
        #
        # NOTE: Rather than using bare `home.arpa`, claim a namespace under it
        # (`<name>.home.arpa`) — the same idea as Tailscale's per-tailnet names
        # (https://tailscale.com/docs/concepts/tailnet-name). If home networks
        # ever get bridged (site-to-site VPN, merged households, a friend's
        # lab) or you run several networks, namespaced hosts and service
        # vhosts won't collide, and certs/SSO configs stay unambiguous.
        #
        # Generate a name for your own network:
        #   nix run nixpkgs#rust-petname   # memorable, e.g. "casual-mullet"
        #   openssl rand -hex 2            # short & random, e.g. "8ke2"
        domain = lib.mkOption {
          type = lib.types.str;
          default = "madhouse.home.arpa";
          example = "casual-mullet.home.arpa";
          description = ''
            The domain homelab services are served under.
            Prefer a unique namespace under home.arpa (RFC 8375), or a public
            domain you own. The real value is private and set in `nixos-secrets`.
          '';
        };
      };

      config = {
        networking.domain = lib.mkDefault config.zw.homelab.domain;
      };
    };
}
