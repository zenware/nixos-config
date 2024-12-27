{
  description = "Configuration for NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
  };
  outputs = inputs@{self, nixpkgs, nixos-hardware, ...}:
  {
    nixosConfigurations = {
      neon = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # https://github.com/NixOS/nixos-hardware/blob/master/README.md#using-nix-flakes-support
          nixos-hardware.nixosModules.gpd-pocket-3
          ./configuration.nix
           # override from nixos-hardware
          ({config, lib, ...}: { services.xserver.videoDrivers = lib.mkForce [ "modesetting" ]; })
        ];
      };
    }; 
  };
}
