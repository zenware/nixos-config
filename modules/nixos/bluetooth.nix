{ config, lib, ... }:
{
  hardware.bluetooth = {
    enable = lib.mkDefault true;
    powerOnBoot = lib.mkDefault true;
  };

  services.blueman.enable = lib.mkDefault true;
}
