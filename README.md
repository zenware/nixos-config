# nixos-config

> Declarative, reproducible configuration for all my NixOS systems
> Covers workstation/gaming, laptop, and homelab/server use cases.

## Overview

This repository manages **multiple NixOS systems** using a shared modular configuration.
It's designed to be **secure, composable, and automated** using modern Nix tooling.

- **Laptop ("neon")**: Portable KVM/Swiss-Army Knife
- **Homelab Server ("lithium")**: Identity, Backups, Forgejo, Jellyfin
- **Workstation / Gaming ("titanium")**: Dev and Gaming /w Steam/Proton
- Secrets managed via `sops-nix`
- Deployable with `nixos-rebuild` (and soon `deploy-rs` or `nixos-anywhere`)

Goofing
```bash
nix --extra-experimental-features repl-flake repl ".#nixosConfigurations.titanium"
nix repl --expr "builtins.getFlake \"$PWD\""
```

```mermaid
---
title: How it all fits together
---
graph TD
    subgraph Entrypoint
        flake
        mkSystem
    end
    subgraph System Configuration
        hosts
        hosts_conf
        hosts_hardware
    end
    subgraph User Configuration
        users_default
        users_home
    end
    subgraph Shared Modules
      nixos_mods
      home_mods
    end
    flake["flake.nix"] --> mkSystem["lib/mkSystem"]
    
    mkSystem --> hosts["hosts/{hostname}/default.nix"]
    mkSystem --> users_default["users/{username}/default.nix"]
    mkSystem -.->|if file exists| users_home["users/{username}/home.nix"]
    
    hosts --> nixos_mods@{ shape: docs, label: "modules/nixos/*"}
    hosts --> hosts_conf["configuration.nix"]
    hosts --> hosts_hardware["hardware.nix"]
    
    users_home --> home_mods@{ shape: docs, label: "modules/home/*"}
```

## How to use this? (Deployment)

With [home-manager](https://github.com/nix-community/home-manager) included as
an input to the flake, and pulled into the hosts along with their users, this
will automatically apply updates to both the system and user environments.


```bash
# This will show what the flake has to offer.
nix flake show

# Build a VM to test config
nixos-rebuild build-vm --flake .#hostname

# Preview and apply changes on a nixOS system
nixos-rebuild dry-run --flake .#hostname
sudo nixos-rebuild switch --flake .#hostname

# Preview and apply changes on a macOS system
darwin-rebuild dry-run --flake .#hostname
darwin-rebuild switch --flake .#hostname

# Generate an Install ISO
nix build .#nixosConfigurations.installIso.config.system.build.images.iso

# Verify the ISO contents
sudo mount -o loop result/iso/nixos-*.iso mnt
ls mnt
umount mnt

# Generate Service and Network Topology Diagrams
nix build .#topology.x86_64-linux.config.output

# Build a top-level system for validation
nix build .#nixosConfigurations.${hostname}.config.system.build.toplevel
```

### Home Manager

NixOS and nix-darwin hosts include Home Manager in their system
configurations. On those machines, applying the system configuration also
applies the matching home configuration.

Standalone targets remain available for systems where NixOS or nix-darwin is
not managed by this flake, such as corporate-managed machines and WSL:

```bash
home-manager switch --flake .#jml          # Linux desktop
home-manager switch --flake .#jml-headless # headless Linux or WSL
home-manager switch --flake .#jml-darwin   # standalone macOS
```

For managed hosts such as `lithium`, use the system configuration. The
integrated Home Manager configuration is applied by `nixos-rebuild`:

```bash
sudo nixos-rebuild switch --flake .#lithium
```

Do not use a standalone target and an integrated Home Manager configuration as
independent owners of the same home directory.

### Setup a macbook

This is different from standard NixOS systems in that... it's literally not NixOS, and also
becuase the Lix distribution is better in this scenario.

Lix has a nicer install/uninstall cycle if you need that.
```bash
# https://lix.systems/install/#on-any-other-linuxmacos-system
curl -sSf -L https://install.lix.systems/lix | sh -s -- install

# https://git.lix.systems/lix-project/lix-installer#uninstalling
/nix/lix-installer uninstall

# First run of nix-darwin
sudo -H nix run nix-darwin/master#darwin-rebuild -- switch --flake .#m5mbp

# Subsequent runs of nix-darwin
sudo -H darwin-rebuild switch --flake .#m5mbp
```

## Design Goals

- **Reproducibility**: All systems can be rebuilt from this repo
- **Modularity**: Every services is a reusable module
- **Security**: Minimal trust, secrets managed explicitly
- **Composability**: Roles + services enable rapid provisioning

## Directory Layout / Organization

```
├── flake.nix  # sets inputs, imports lib functions, wires hosts and users
├── lib        # functions to build flake outputs
├── hosts
│   ├── <hostname>
│   │   ├── configuration.nix  # imports from ../../modules/nixos
│   │   ├── hardware.nix       # host specific hardware configuration
│   │   └── default.nix        # entrypoint for host configuration
├── users
│   ├── <username>
│   │   ├── default.nix  # entrypoint for user configuration
│   │   └── home/default.nix     # imports from ../../modules/home/
├── modules    # Reusable NixOS and Home-Manager Modules
│   ├── nixos  # host configuration modules
│   └── home   # home-manager modules
├── overlays   # Custom Nixpkgs overlays that modify existing pacakges.
└── pkgs       # Custom Nix packages (not in nixpkgs)

```

## Topology

![Network and Service Topology Diagram](assets/topology/main.svg)

## References

- [@shazow](https://github.com/shazow/) and https://github.com/shazow/nixfiles/
- [@ryan4yin] and the contributors and co-authors of [nixos-and-flakes-book](https://nixos-and-flakes.thiscute.world/)
- [@Mic92] for https://github.com/Mic92/sops-nix and https://blog.thalheim.io/
- Various GitHub Projects found with searches [similar to this](https://github.com/search?q=language%3ANix+sops-nix.nixosModules.sops&type=code)
- https://nix.dev/ and https://search.nixos.org/
- https://edolstra.github.io/pubs/phd-thesis.pdf
