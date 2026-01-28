{ inputs, ... }:
{
  imports = [
    ./boot.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/audio.nix
    #../../modules/nixos/desktop.nix
    # https://github.com/NixOS/nixos-hardware/blob/master/README.md#using-nix-flakes-support
    # TODO: This module doesn't exist yet.
    #inputs.nixos-hardware.nixosModules.asus-zenbook-ux390u
    #/home/jml/Workspace/nixos-hardware/asus/zenbook/ux390ua
    ./hardware-configuration.nix
    ./configuration.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/desktop/xfce
    #../../modules/nixos/desktop/niri
  ];

  zw.gaming.enable = true;
}
