{ config, inputs, ... }:
let
  inherit (config.flake.lib) mkSystem;
in
{
  # NOTE: Run `nix flake show` to see what this flake has to offer.
  # TODO: Enable automated formatting with something like numtide/treefmt-nix
  flake.nixosConfigurations = {
    titanium = mkSystem {
      hostname = "titanium";
      users = [
        "jml"
      ];
      extraModules = [
        #(import ../../overlays)
        inputs.determinate.nixosModules.default
        inputs.microvm.nixosModules.host
      ];
    };
    # The following command is a great recovery image for lithium.
    # nixos-rebuild build-image --image-variant iso --flake .#lithium
    lithium = mkSystem {
      hostname = "lithium";
      #specialArgs = {inherit inputs;};
      # NOTE: Rather than declare extraModules here, we override them in `nixos-secrets`
      #extraModules = [ inputs.microvm.nixosModules.host ];
      users = [
        "jml"
        "breakglass"
      ];
    };
    cobalt = mkSystem {
      hostname = "cobalt";
      users = [ "jml" ];
    };
    neon = mkSystem {
      hostname = "neon";
      users = [ "jml" ];
    };
    # https://nixos.org/manual/nixos/stable/#sec-image-nixos-rebuild-build-image
    # nixos-rebuild build-image --image-variant iso --flake .#installIso
    # TODO: Enable nix-command and flakes system-wide
    installIso = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        {
          hardware.enableRedistributableFirmware = true;

          # Required despite not booting from zfs, in order to make zfs.ko available to modprobe.
          # https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html#installation
          boot.supportedFilesystems = [ "zfs" ];
          boot.zfs.forceImportRoot = false;

          # Kmods used on lithium, which is usually where I run this media..
          boot.initrd.availableKernelModules = [
            "xhci_pci"
            "ahci"
            "mpt3sas"
            "nvme"
            "usbhid"
            "usb_storage"
            "sd_mod"
            "sr_mod"
          ];
          boot.initrd.kernelModules = [ ];
          boot.kernelModules = [ "kvm-intel" ];
          boot.extraModulePackages = [ ];

          environment.systemPackages = with inputs.nixpkgs.legacyPackages.x86_64-linux; [
            # Filesystems / RAID
            btrfs-progs
            xfsprogs
            e2fsprogs
            dosfstools
            zfs
            mdadm
            lvm2
            gptfdisk
            pardted

            # Disk health / recovery
            smartmontools
            nvme-cli
            hdparm
            testdisk # testdisk + photorec - partition/file recovery
            gddrescue # ddrescue - imaging a failing disk sector-by-sector

            # Hardware / bus inspection
            pciutils # lspci
            usbutils # lsusb
            dmidecode # board/BIOS/RAM SPD info without rebooting into BIOS
            lshw

            # Networking / remote access
            ethtool
            iproute2
            curl
            wget
            socat

            # Process/system diagnostics
            strace
            lsof
            htop
            file

            # General / Comfort
            zellij
            ripgrep
            git
            jq
          ];

          services.openssh = {
            enable = true;
            settings = {
              PermitRootLogin = "yes";
              PasswordAuthentication = false;
            };
          };
          users.users.root = {
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWnk0plf2FvpUm5nsOnR6wbY5xodV6hgdI1WpBvbroV jml@titanium"
            ];
          };
          services.getty.autologinUser = inputs.nixpkgs.lib.mkForce "root";
          networking.firewall.enable = false; # trusted LAN, transient rescue/install media
        }
      ];
      specialArgs = { inherit inputs; };
    };
  };

  # NOTE: m5mbp is as much a host machine as the rest; it just boots darwin,
  # so it lives under darwinConfigurations instead of nixosConfigurations.
  flake.darwinConfigurations = {
    m5mbp = inputs.nix-darwin.lib.darwinSystem {
      modules = [ ../../hosts/m5mbp/configuration.nix ];
      specialArgs = {
        inherit inputs;
        homeManagerModules = config.flake.modules.homeManager;
      };
    };
  };
}
