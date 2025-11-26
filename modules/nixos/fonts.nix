{pkgs}:
{
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.iosevka
    atkinson-hyperlegible
  ];
}