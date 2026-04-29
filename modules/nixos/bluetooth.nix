{ config, lib, ... }:
{
  options.zw.bluetooth = {
    enable = lib.mkEnableOption "Enable Bluetooth";
  };

  config = {
    hardware.bluetooth = {
      enable = lib.mkDefault true;
      #powerOnBoot = lib.mkDefault true;
    };

    services.blueman.enable = lib.mkDefault true;
  };
}
