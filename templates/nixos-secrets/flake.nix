{
  description = "nixos-secrets, the private part of zenware/nixos-config";
  inputs = {
    nixos-config.url = "github:zenware/nixos-config";
    nixpkgs.follows = "nixos-config/nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    inputs@{
      nixos-config,
      nixpkgs,
      sops-nix,
      ...
    }:
    let
      pkgs = nixpkgs;
      mkSystem = nixos-config.lib.mkSystem;
    in
    {
      # TODO: Some massaging necessary on which hosts have secrets, and how their
      # private module structure works.
      nixosConfigurations = {
        lithium = mkSystem {
          hostname = "lithium";
          users = [
            "breakglass"
            "jml"
          ];
          extraModules = [
            sops-nix.nixosModules.sops
            # NOTE: zw.homelab.domain is declared in nixos-config
            # (modules/flake/homelab.nix); set your real domain here to keep
            # it out of the public configuration.
            #
            # Use a public domain you own, or claim a unique namespace under
            # home.arpa (RFC 8375) — like Tailscale's per-tailnet names
            # (https://tailscale.com/docs/concepts/tailnet-name) — so nothing
            # collides if home networks are ever bridged. Generate one with:
            #   nix run nixpkgs#rust-petname   # memorable, e.g. "casual-mullet"
            #   openssl rand -hex 2            # short & random, e.g. "8ke2"
            { zw.homelab.domain = "casual-mullet.home.arpa"; }
            ./modules/nixos/private-config
          ];
        };
      };
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixpkgs-fmt
          sops
        ];
      };
    };
}
