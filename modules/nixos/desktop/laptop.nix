{ config, pkgs, ... }:
{
  options = {
    zw.laptop.enable = lib.mkEnableOption "Enable Laptop";
  };

  config = lib.mkIf config.zw.gaming.enable {
    # Power management (especially important for laptops)
    services.power-profiles-daemon.enable = lib.mkDefault true;
    # OR use tlp instead:
    # services.tlp.enable = lib.mkDefault false;

    # Brightness Control
    environment.systemPackages = with pkgs; [
      brightnessctl
    ]

    # Enable location services (optional, useful for night light)
    services.geoclue2.enable = lib.mkDefault true;

    # Laptop-specific hardware
    services.upower.enable = true;
  }
}