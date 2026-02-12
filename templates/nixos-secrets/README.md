# nixos-secrets template

This template is the private overlay for a public NixOS configuration. It is meant to hold **secret material** and **private configuration** that you do not want in the public repo.
It's unlikely to be the best way to set this up, but it is representative of what I'm actually doing today.

## Layout

```
.
├── flake.nix
├── global/                  # Optional shared secrets or shared private config
├── lithium/                 # Host-specific secrets and private config
└── modules/nixos/private-config
    └── default.nix          # Private service config module(s)
```

## Quick start

1. Copy this template into your own private repo.
2. Replace the `nixos-config` input in [flake.nix](flake.nix) with your public config source (e.g. GitHub URL).
3. Add your host secrets under the host directory (e.g. [lithium/](lithium/)).
4. Put private service wiring in [modules/nixos/private-config/default.nix](modules/nixos/private-config/default.nix).

```bash
mkdir nixos-secrets & cd nixos-secrets
nix flake init -t github:zenware/nixos-config#secrets
```

## Notes

- This repo is intended to **overlay** the public config. It can include private services and secrets that the public repo should not know about.
- SOPS files live under each host directory; add encryption rules and keys appropriate for your environment.
- The public repo does **not** need to reference `private-config` explicitly; this repo’s `flake.nix` wires it in.
