{ ... }:
{
  # Based on: hosts/titanium/disko.nix
  # No LUKS because I want lithium to auto-recover from power failure more than I want encryption.
  # There's 2 500Gb NVME drives and 2 500Gb SSDs, and an HDD zfs pool of 16Tb disks.
  # The SSDs are the boot drives and hold the NixOS system.
  # The NVME drives are ARC2 cache for the ZFS pool.
  # Dry Run: `sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --dry-run /tmp/disk-config.nix`
  # Live Run: `sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disk-config.nix`
  # NOTE: Critically the disks are called main and alt, so that disko lexicographically sorts them and creates 'alt' first.
  # it is not possible to pass extra args to 'disk-main' the way we are otherwise.
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/ata-CT500MX500SSD1_2206E607D6AA";

        content = {
          type = "gpt";

          partitions = {
            ESP = {
              name = "ESP";
              size = "8G";
              type = "EF00";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            root = {
              size = "100%";

              content = {
                type = "btrfs";

                # The first device is the Btrfs filesystem's primary
                # creation/mount device. The second partition becomes
                # the second Btrfs RAID1 member.
                extraArgs = [
                  "-f"
                  "--data"
                  "raid1"
                  "--metadata"
                  "raid1"
                  "/dev/disk/by-id/ata-CT500MX500SSD1_2206E607D728-part2"
                ];

                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };

      alt = {
        type = "disk";
        device = "/dev/disk/by-id/ata-CT500MX500SSD1_2206E607D728";

        content = {
          type = "gpt";

          partitions = {
            ESP = {
              name = "ESP";
              size = "8G";
              type = "EF00";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot-fallback";
                mountOptions = [ "umask=0077" ];
              };
            };

            root = {
              size = "100%";

              # Intentionally no content here.
              #
              # Disko creates the partition, and the Btrfs declaration
              # on ssd-a formats this partition as the second RAID1
              # member.
              type = "8300";
            };
          };
        };
      };
    };
  };
 }
