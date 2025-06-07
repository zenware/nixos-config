# lithium

This is my primary homelab host/NAS, previously powered by TrueNAS Scale/k3s.

## Semi-Secrets

`semi-secret-vars.nix` is following a pattern I discovered here:
  https://github.com/nyawox/arcanum/blob/4629dfba1bc6d4dd2f4cf45724df81289230b61a/var/README.md

Essentially there are some details I won't want exposed in the repository, but
I do want them available to all my nix modules. The main one being the domain.

While it's not really a secret in the way a password is, consider this effort a
mitigation against ddos attacks and automated requests and login attempts.
