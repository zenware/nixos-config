{ inputs, ... }:
{
  imports = [
    ../../modules/nixos/base.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/gaming.nix
    inputs.nixos-hardware.nixosModules.asus-rog-strix-x570e
    ./hardware.nix
    ./configuration.nix
  ];
}
