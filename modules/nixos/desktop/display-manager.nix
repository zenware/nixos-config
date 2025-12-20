{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      accent = "teal";
      font = "Noto Sans";
      fontSize = "9";
      #background = "${./wallpaper.png}";
      loginBackground = true;
    })
    (pkgs.sddm-astronaut.override {
      embeddedTheme = "pixel_sakura";
    })
  ];
  services.displayManager.defaultSession = "niri";

  # TODO: Figure out how to add a session selector to sddm-astronaut-theme.
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    wayland.enable = true;
    #theme = "catppuccin-mocha-teal";
    theme = "sddm-astronaut-theme";
    extraPackages = [ ];
  };
}