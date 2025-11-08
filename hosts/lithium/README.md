# lithium

This is my primary homelab host/NAS, previously powered by TrueNAS Scale/k3s.

## Manual Actions

Even with fully declarative Nix/Nixpkgs/NixOS at the end of the day there are
still some actions that need to be taken manually.

- secrets configuration for `sops-nix`
- kanidm user management
- tailscale auth key
- jellyfin configuration via web-ui

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
