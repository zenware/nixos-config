# titanium

This is my primary workstation / gaming pc.
It will generally be the most out of sync with the repo, as there will be a lot
of software I experiment with, which I simply forget to commit here. Everything
of importance will find it's way to this repo.

## Non-Deterministic Post-Install Steps

Rearrange Monitors in Gnome Display Settings

Use a fido2 key (YubiKey) to decrypt luks
```bash
sudo -E -s systemd-cryptenroll --fido2-device=auto /dev/disk/by-partlabel/disk-main-luks
```

## Installing Remotely
```bash
nix run github:nix-community/nixos-anywhere -- --flake .#titanium <ssh-addr>
```
