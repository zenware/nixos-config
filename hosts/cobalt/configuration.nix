# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  networking.hostName = "cobalt"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;


  #services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "xfce";
  services.displayManager.sessionPackages = [ pkgs.niri ];
  #services.sysc-greet.enable = true;
  programs.niri.package = pkgs.niri;

  services.xserver.desktopManager = {
    xterm.enable = false;
    xfce.enable = true;
  };

  # Desktop stuff specific to this device
  services.xserver.enable = true;
  #services.xserver.displayManager.lightdm.enable = true;
  #services.xserver.desktopManager.pantheon.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.iosevka
    atkinson-hyperlegible
  ];


  system.stateVersion = "25.05";
}
