# lithium

This is my primary homelab host/NAS, previously powered by TrueNAS Scale/k3s.
You can start a test version from the `nixos-config` repo, but in order to run
the production version you need to make a new repo from the secrets template,
and manually configure a selection of secrets both for internal and external
services.

## Manual Actions

Even with fully declarative Nix/Nixpkgs/NixOS at the end of the day there are
still some actions that need to be taken manually.

- secrets configuration `sops-nix`
- kanidm user management
- tailscale auth key
- jellyfin configuration via web-ui

## Kanidm Administration

NixOS declares the Kanidm service account and state directory, but standalone
commands do not inherit the systemd service account. Keep the command types
separate:

- `kanidmd` performs local database maintenance; run it as `kanidm`.
- `kanidm` is the remote client; run it as a human administrator.
- `systemctl` and `journalctl` are host administration commands; use `sudo`.

For commands that inspect or lock the local database, stop the service first:

```sh
sudo systemctl stop kanidm.service
sudo -u kanidm -- kanidmd domain upgrade-check
sudo -u kanidm -- kanidmd configtest -c /etc/kanidm/server.toml
sudo systemctl start kanidm.service
sudo journalctl -u kanidm.service -b
```

An administrator normally establishes a client session before managing
accounts:

```sh
kanidm login --name idm_admin
kanidm reauth -D idm_admin
kanidm person get <account_id> --name idm_admin
kanidm person credential create-reset-token <account_id> --name idm_admin
kanidm person credential update <account_id> --name idm_admin
kanidm person posix set --name idm_admin <account_id>
kanidm person posix set-password --name idm_admin <account_id>
kanidm person posix show --name anonymous <account_id>
kanidm person validity expire-at <account_id> now --name idm_admin
kanidm person validity expire-at <account_id> clear --name idm_admin
```

Prefer a reset token when onboarding or recovering a user so they can enroll
their own credentials. Use account expiry to disable an account rather than
deleting credentials. The declarative provisioning configuration manages
account metadata and group membership, not users' passkeys, passwords, MFA
credentials, or POSIX attributes/passwords.

## Secrets and "Private Information"

Originally I had used two providers of secrets, `sops-nix` and `git-agecrypt`,
and the reasoning for that was, with `git-agecrypt` I could directly encrypt an
entire `.nix` file, and use it to conceal an arbitrary amount of my nix config.
The #1 thing I was using it for was hiding details about the domain names that
power various services. I know that's not real security, and domains aren't
really private, but server logs prove that not including a domain in a GH repo
means you get dramatically fewer spurious requests.

The reason for using `git-agecrypt` against a whole nix file like that was most
importantly because it allowed me to *just use nix variables*. Compared to the
invocationss SOPS & `sops-nix` require, it can be a lot more simple for setting
values like a domain name.

Now I'm going all in on `sops-nix` as the exclusive manager of secrets, and
maintaining a separate flake which contains private nix configuration details.
There are still issues with this, and now my overall nix config is essentially
fractured between "flake-A" and "flake-B", which gives me all the same issues
that any other software project faces with that arrangement. But I dislike
using `git-agecrypt` even more than I dislike those problems.
