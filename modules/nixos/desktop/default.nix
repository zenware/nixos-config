{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./calibre.nix
    #../base.nix imported by the host
    ../audio.nix
    ../fonts.nix
    ../bluetooth.nix
    ../gaming.nix
    # Desktop Environments
    ./display-manager.nix
    ./hyprland
    ./niri
    ./xfce
  ];

  # TODO: Add options for enabling/switching between different Desktop Environments.
  # options.zw.desktop = {
  #   enable = lib.mkEnableOption "desktop environment";
  #   compositor = lib.mkOption {
  #     type = lib.types.enum [ "hyprland" "niri" "xfce" ];
  #     default = "niri";
  #     description = "Which compositor/DE to use";
  #   };
  # };

  # NOTE: Calibre is enabled this way because it also needs udisks2 for e-readers
  # TODO: Reorganize this to somewhere else.
  zw.calibre.enable = true;

  # Desktop Notifications: https://wiki.archlinux.org/title/Desktop_notifications

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    displayManager.startx.enable = lib.mkDefault false;
  };

  # https://wiki.archlinux.org/title/XDG_Desktop_Portal#List_of_backends_and_interfaces
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # Fallback for file picker, etc.
    ];
    xdgOpenUsePortal = true;
  };

  networking.networkmanager.enable = lib.mkDefault true;

  # Authentication Agent (polkit) - required for privilege escalation in GUI apps
  security.polkit.enable = lib.mkDefault true;

  # Keyring for storing secrets
  # NOTE: Instead of gnome-keyring, I'm using KeePassXC
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  # Thumbnail support for file managers
  services.tumbler.enable = true;

  environment.sessionVariables = {
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    # System Utilities
    networkmanagerapplet # Tray Icon for managing network connections
    yubikey-personalization

    # Display Manager Configuration Tools (for laptops)
    wlr-randr # A CLI tool for configuring monitors on Wayland (e.g., Hyprland)
    pavucontrol # Graphical Volume Mixer (PulseAudio/PipeWire)
    # gnome.file-roller -- Just use tar
    feh # Simple image viewer (or a wayland alternative)
    clipman # Wayland clipboard manager

    # App Launchers
    rofi
    wofi
    fuzzel

    # Status bar (if not using compositors built-in)
    waybar

    # Wallpaper managers
    swww

    # Terminal Emulators
    alacritty
    wezterm

    # File manager
    xfce.thunar
    xfce.thunar-volman # Removable Media
    gvfs # Trash support and more

    # Wayland Utilities
    wl-clipboard
    wlr-randr
    wayland-utils

    # Screenshot and screen recording
    grim
    slurp
    wf-recorder

    # Notification Daemon (choose one) - https://wiki.archlinux.org/title/Desktop_notifications
    mako
    # dunst

    # Clipboard manager
    cliphist
  ];

  # Enable dconf (System configuration database)
  # https://wiki.archlinux.org/title/GNOME#Configuration
  programs.dconf.enable = true;

  # NOTE: This is closer to being host-specific or at least, not necessary on every system which has a desktop environment.
  # udev rules for certain ahrdware (game controllers, etc.)
  # services.udev.packages = with pkgs; [ ]; # add any specific udev rules you need

  # Enable printing support (optional)
  services.printing.enable = lib.mkDefault true;

  # Scanner support (optional)
  services.saned.enable = lib.mkDefault false;

  # Flatpak support (optional)
  services.flatpak.enable = lib.mkDefault false;

  # System-wide progams that benefit desktop users
  # NOTE: Maybe we don't have these?

  # Allow users to mount filesystems without root
  programs.fuse.userAllowOther = true;

  services.avahi.enable = lib.mkDefault true; # zeroconf/mDNS(.local)
}
