# lithium

This is my primary homelab host/NAS, previously powered by TrueNAS Scale/k3s.

## Manual Actions

Even with fully declarative Nix/Nixpkgs/NixOS at the end of the day there are
still some actions that need to be taken manually.

- secrets configuration (both for SOPS and git-agecrypt semi-secrets)
- kanidm user management
- tailscale auth key
- jellyfin configuration via web-ui

## Semi-Secrets

`semi-secret-vars.nix` is using [git-agecrypt](https://github.com/vlaci/git-agecrypt)
and following a pattern I discovered here:
 - https://github.com/nyawox/arcanum/blob/4629dfba1bc6d4dd2f4cf45724df81289230b61a/var/README.md
 - https://github.com/vlaci/git-agecrypt

Essentially there are some details I won't want exposed in the repository, but
I do want them available to all my nix modules. The main one being the domain.

While it's not really a secret in the way a password is, consider this effort a
mitigation against ddos attacks and automated requests and login attempts.
