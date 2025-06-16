{ inputs, ... }:
{
  imports = [
    ../../modules/nixos/base.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/desktop.nix
    # https://github.com/NixOS/nixos-hardware/blob/master/README.md#using-nix-flakes-support
    inputs.nixos-hardware.nixosModules.gpd-pocket-3
     # override from nixos-hardware
    ({config, lib, ...}: { services.xserver.videoDrivers = lib.mkForce [ "modesetting" ]; })
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
