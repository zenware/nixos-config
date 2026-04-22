{ pkgs, ... }:
{
  # NOTE: Attempt to enable automatic MTP for Kindle + Android
  # Add user to 'storage' group?
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    jmtpfs
    gvfs
    libmtp
  ];

  services.udev.extraRules = ''
    # Amazon Kindle (generic MTP rule)
    SUBSYSTEM=="usb", ATTR{idVendor}=="1949", MODE="0664", GROUP="plugdev"
  '';

  users.users.jml.extraGroups = [ "plugdev" ];
  
}
