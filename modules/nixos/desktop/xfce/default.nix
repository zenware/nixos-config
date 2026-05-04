{ config, lib, ... }:
{
  config = lib.mkIf (config.zw.desktop.enable && config.zw.desktop.compositor == "xfce") {
    #services.displayManager.defaultSession = "xfce";
    services.xserver.desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
}
