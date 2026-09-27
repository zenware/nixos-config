{ ... }:
{
  boot.initrd.systemd.enable = true; # Wait for 'btrfs device ready'
  boot.initrd.systemd.emergencyAccess = true;
  boot.kernel.sysctl."kernel.sysrq" = 1;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    #efiInstallAsRemovable = false;
    copyKernels = true;
    mirroredBoots = [
      {
        path = "/boot";
        efiSysMountPoint = "/boot";
        devices = [ "nodev" ];
      }
      {
        path = "/boot-fallback";
        efiSysMountPoint = "/boot-fallback";
        devices = [ "nodev" ];
      }
    ];
  };
}
