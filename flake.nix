{
  description = "Configuration for NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{self, nixpkgs, nixos-hardware, sops-nix, ...}:
  {
    nixosConfigurations = {
      neon = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # https://github.com/NixOS/nixos-hardware/blob/master/README.md#using-nix-flakes-support
          nixos-hardware.nixosModules.gpd-pocket-3
          ./hosts/neon
           # override from nixos-hardware
          ({config, lib, ...}: { services.xserver.videoDrivers = lib.mkForce [ "modesetting" ]; })
        ];
      };
      lithium = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/lithium
          sops-nix.nixosModules.sops
        ];
      };
    }; 
  };
}
