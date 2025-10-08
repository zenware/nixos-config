{ config, lib, pkgs, ... }:
{
  imports = [];

  options = {
    zw-calibre = {
      enable = lib.mkEnableOption "Enable Calibre";
    };
  };

  config = {
    config.allowUnfreePredigate = pkg: builtins.elem (lib.getName pkg) [
      "calibre"
      "unrar"
    ];

    environment.systemPackages = with pkgs; [
      (calibre.override {
        unrarSupport = true;
      })
      unrar
    ];

    services.udisks2.enable = true;
  };
  # NOTE: Consider adding https://github.com/nydragon/calibre-plugins
}
