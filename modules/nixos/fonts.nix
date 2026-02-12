{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      atkinson-hyperlegible

      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      font-awesome

      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      # dejavu_fonts
    ];

    # TODO: Explore other default fonts, particularly atkinson-hyperlegible
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "FiraCode Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
