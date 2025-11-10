{ config, lib, pkgs, ... }:
{
  imports = [];

  options = {
    zw.calibre = {
      enable = lib.mkEnableOption "Enable Calibre";
    };
  };
  
  config = {
    # NOTE: Without unrar support we can't open ".cbr" files.
    environment.systemPackages = with pkgs; [
      calibre
    ];

    services.udisks2.enable = true;
  };
  # NOTE: Consider adding https://github.com/nydragon/calibre-plugins
}
