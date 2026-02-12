{
  config,
  pkgs,
  lib,
  ...
}:
{
  # For real-time audio/production consider: https://github.com/musnix/musnix
  security.rtkit.enable = lib.mkDefault true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
    wireplumber.enable = true;
  };

  # Graphical Volume Mixer
  environment.systemPackages = with pkgs; [
    pavucontrol
  ];
}
