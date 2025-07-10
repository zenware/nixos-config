{ inputs, ... }:
{
  imports = [
    ../../modules/nixos/base.nix
    ../../modules/nixos/audio.nix
    #../../modules/nixos/desktop.nix
    # https://github.com/NixOS/nixos-hardware/blob/master/README.md#using-nix-flakes-support
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
