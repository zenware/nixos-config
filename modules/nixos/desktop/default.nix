{ pkgs, ... }:
{
  imports = [
    ./calibre.nix
    ./fonts.nix
  ];

  zw.calibre.enable = true;

  environment.systemPackages = with pkgs; [
    yubikey-personalization
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xwayland
    rofi
    waybar
    hyprpaper
    kitty # hyprland default term
    swww # wallpaper
  ];
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.printing.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  programs.hyprlock.enable = true;
  # Hint electron apps to use wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  # screen sharing /w hyp 
  services.dbus.enable = true;
}
