# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

let
  ux390AlsaPaths = pkgs.runCommand "ux390-alsa-mixer-paths" { } ''
    cp -r ${pkgs.pipewire}/share/alsa-card-profile/mixer/paths "$out"
    chmod -R u+w "$out"

    substituteInPlace "$out/analog-output.conf.common" \
      --replace-fail \
      '[Element PCM]
    switch = mute
    volume = merge
    override-map.1 = all
    override-map.2 = all-left,all-right' \
      '[Element Master]
    switch = mute
    volume = ignore

    [Element PCM]
    switch = mute
    volume = merge
    override-map.1 = all
    override-map.2 = all-left,all-right

    [Element LFE]
    switch = mute
    volume = ignore'
  '';
in
{
  networking.hostName = "cobalt"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # The UX390UAK incorrectly reports that it is always in tablet mode.
  environment.etc."libinput/local-overrides.quirks".text = ''
    [ASUS Zenbook UX390 touchpad]
    MatchUdevType=touchpad
    ModelTabletModeNoSuspend=1

    [ASUS Zenbook UX390 keyboard]
    MatchUdevType=keyboard
    ModelTabletModeNoSuspend=1
  '';

  # Its surround-sound mixer needs these elements ignored for volume controls
  # to produce levels between muted and full volume.
  systemd.user.services.wireplumber.environment.ACP_PATHS_DIR = "${ux390AlsaPaths}";

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
