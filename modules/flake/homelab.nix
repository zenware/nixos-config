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
        domain = lib.mkOption {
          type = lib.types.str;
          default = "home.arpa";
          example = "example.com";
          description = ''
            The domain homelab services are served under.
            The real value is private and set in `nixos-secrets`.
          '';
        };
      };

      config = {
        networking.domain = lib.mkDefault config.zw.homelab.domain;
      };
    };
}
