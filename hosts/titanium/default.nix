{ inputs, pkgs, ... }:
let
  nixpkgs = inputs.nixpkgs;
in
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = (import (../../overlays) {inherit nixpkgs;});
  imports = [
    ../../modules/nixos/base.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/desktop
    ../../modules/nixos/gaming.nix
    inputs.nixos-hardware.nixosModules.asus-rog-strix-x570e
    ./hardware.nix
    ./configuration.nix
    ./nvidia.nix
    inputs.lanzaboote.nixosModules.lanzaboote
    ./secure-boot.nix
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./game-emulation.nix
    #./meetings.nix
  ];

  zw.gaming.enable = true;

  stylix = {
    #enable = true;
    # catppuccin-mocha
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    # image = ./path.png; polarity = "dark"; # /etc/stylix/palette.html
    # TODO: Add Atkinson Hyperlegible Next, Mono, and also a good Serif font.
    # https://search.nixos.org/packages?channel=unstable&show=atkinson-hyperlegible-next&query=atkinson
    # fonts = {
    #   serif = {};
    #   sansSerif = {};
    #   monospace = {};
    #   emoji = {};
    # };
  };
}
