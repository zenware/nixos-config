{ pkgs, ... }:
{
  # For real-time audio/production consider: https://github.com/musnix/musnix
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
  ];
}
