{ config, pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

  xdg.portal.config.hyprland = {
    default = [ "hyprland" "gtk" ];
    "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
    "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
  };

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-hyprland
    kitty # Hyprland default term
    # Hyprland-specific tools
    hyprpaper
    hypridle
    hyprlock
  ];

  programs.hyprlock.enable = true;
}