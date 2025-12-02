{ ... }:
{
  services.displayManager.defaultSession = "xfce";
  services.xserver.desktopManager = {
    xterm.enable = false;
    xfce.enable = true;
  };

}