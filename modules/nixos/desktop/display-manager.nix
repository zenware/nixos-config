{ pkgs, config, ... }:
let
  custom-astronaut-theme = pkgs.sddm-astronaut.override {
    embeddedTheme = "pixel_sakura";
  };
in
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
    custom-astronaut-theme
    # NOTE: Packages below here may be consumed by themes.
    pkgs.kdePackages.qtbase
    pkgs.kdePackages.qtwayland
    pkgs.kdePackages.qtmultimedia
  ];
  services.displayManager.defaultSession = config.zw.desktop.compositor;

  # TODO: Figure out how to add a session selector to sddm-astronaut-theme.
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    wayland.enable = true;
    #theme = "catppuccin-mocha-teal";
    theme = "sddm-astronaut-theme";
    extraPackages = [ custom-astronaut-theme ];
  };
}
