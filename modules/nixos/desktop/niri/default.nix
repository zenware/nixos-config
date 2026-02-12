{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # Opinionated Niri Setup - https://yalter.github.io/niri/Important-Software.html
  # Consider: https://github.com/sodiboo/niri-flake

  # NOTE: Rather than individual components, I'm going to start with a complete desktop shell if possible.
  # According to the docs there's a few options: https://yalter.github.io/niri/Getting-Started.html#desktop-environments
  # LXQt, many parts of XFCE, COSMIC + `cosmic-ext-extra-sessions`
  # And what I actually want to try out is one of DankMaterialShell or Noctalia
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    xwayland-satellite
    fuzzel
    kitty
    fastfetch
  ];

  services.displayManager.sessionPackages = [ pkgs.niri ];

  # Deploy ${./config.kdl} to `~/.config/niri/config.kdl`

  # Notification Daemon
  #services.mako.enable = true;
  #services.mako.settings.default-timeout = 3000;

  # Portal - https://wiki.archlinux.org/title/XDG_Desktop_Portal#List_of_backends_and_interfaces

  # Xwayland
  # https://github.com/Supreeeme/xwayland-satellite
  #programs.xwayland.enable = lib.mkDefault true;

  # Screencasting - https://yalter.github.io/niri/Screencasting.html
  # Needs D-Bus, pipewire, `xdg-desktop-portal-gnome`? Or a portal from the above table with screencasting support

}
