{ config, pkgs, lib, ... }:
{
  services.desktopManager.gnome.enable = true;
  services.displayManager.sddm.enable = lib.mkForce false;

  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    dconf-editor
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-music
    gnome-photos
    gnome-tour
    epiphany
    geary
  ];
}