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
    #./llm-agents.nix
  ];

  zw.gaming.enable = true;

  # Added uv/uvx so I could use github/spec-kit, global specify CLI might be better.
  environment.systemPackages = [
    pkgs.uv  # Python uv/uvx
    pkgs.spec-kit  # Just directly add spec-kit then and see if that's any good.
  ];

  stylix = {
    enable = true;
    polarity = "dark";
    # catppuccin-mocha
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    # image = ./path.png; polarity = "dark"; # /etc/stylix/palette.html
    # TODO: Add Atkinson Hyperlegible Next, Mono, and also a good Serif font.
    # NOTE: What actually are the best fonts and why?
    # https://search.nixos.org/packages?channel=unstable&show=atkinson-hyperlegible-next&query=atkinson
    # fonts = {
    #   serif = {};
    #   sansSerif = {};
    #   monospace = {};
    #   emoji = { package = pkgs.noto-fonts-color-emoji; name = "Noto Color Emoji"; };
    # };
  };
}
