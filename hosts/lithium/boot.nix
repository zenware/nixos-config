{ ... }:
{
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
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
