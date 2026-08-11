{ pkgs, ... }:
{
  # USB storage devices use udisks2/devmon/GVFS. MTP devices can use
  # simple-mtpfs as a manual FUSE fallback.
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    simple-mtpfs
    gvfs
    libmtp
  ];

  services.udev.extraRules = ''
    # Amazon Kindle USB access
    SUBSYSTEM=="usb", ATTR{idVendor}=="1949", MODE="0664", GROUP="plugdev"
  '';

  users.users.jml.extraGroups = [ "plugdev" ];
}
