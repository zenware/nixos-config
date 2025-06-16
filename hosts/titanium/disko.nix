{ ... }:
{
  # Based on:
  # https://github.com/nix-community/disko/blob/master/example/luks-btrfs-subvolumes.nix
  #
  # Run with:
  # `sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disk-config.nix`
  disko.devices = {
    disk = {
      main-disk = {
	      type = "disk";
	      device = "/dev/disk/by-path/pci-0000:08:00.0-ata-2";
	      content = {
		type = "gpt";
		partitions = {
		  ESP = {
		    size = "512M";
		    type = "EF00";
		    content = {
		      type = "filesystem";
		      format = "vfat";
		      mountpoint = "/boot";
		      mountOptions = [ "umask=0077" ];
		    };
		  };
		  luks = {
		    size = "100%";  # Full Disk Encryption
		    content = {
		      type = "luks";
		      name = "crypted";
		      # disable settings.keyFile if you want to use interactive password entry
		      # passwordFile = "/tmp/secret.key";  # Interactive
		      settings = {
			allowDiscards = true;
			#keyFile = "/tmp/secret.key";
		      };
		      #additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
		      content = {
			type = "btrfs";
			extraArgs = [ "-f" ];  # What?
			subvolumes = {
			  "/root" = {
			    mountpoint = "/";
			    mountOptions = [
			      "compress=zstd"
			      "noatime"
			    ];
			  };
			  "/home" = {
			    mountpoint = "/home";
			    mountOptions = [
			      "compress=zstd"
			      "noatime"
			    ];
			  };
			  "/nix" = {
			    mountpoint = "/nix";
			    mountOptions = [
			      "compress=zstd"
			      "noatime"
			    ];
			  };
			  "/swap" = {
			    mountpoint = "/.swapvol";
			    swap.swapfile.size = "16G";
			  };
			};
		      };
		    };
		  };
		};
	      };
	};
    };
  };
}
