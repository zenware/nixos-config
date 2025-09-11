{
  description = "Configuration for NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.3";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };
  # https://nix.dev/tutorials/nix-language.html#named-attribute-set-argument
  outputs = inputs@{self, nixpkgs, nixos-hardware, home-manager, sops-nix, lanzaboote, disko, stylix, ...}:
  let
    mkSystem = (import ./lib {
      inherit nixpkgs home-manager inputs;
    }).mkSystem;
  in
  {
    lib = {
      mkSystem = mkSystem;
    };
    # NOTE: Run `nix flake show` to see what this flake has to offer.
    # TODO: Enable automated formatting with something like numtide/treefmt-nix
    nixosConfigurations = {
      neon = mkSystem {
        hostname = "neon";
        users = [ "jml" ];
      };
      lithium = mkSystem {
        hostname = "lithium";
        # extraModules = [ inputs.sops-nix.nixosModules.sops ];
        users = [
          "jml"
          "breakglass"
        ];
      };
      titanium = mkSystem {
        hostname = "titanium";
        users = [
          "jml"
        ];
        extraModules = [
          #(import ./overlays)
          #stylix.nixosModules.stylix
          { nixpkgs.config.allowUnfree = true; }
          lanzaboote.nixosModules.lanzaboote
          disko.nixosModules.disko
          ./hosts/titanium/disko.nix
          ({ pkgs, lib, ... }: {
            environment.systemPackages = [ pkgs.sbctl ];
            boot.loader.systemd-boot.enable = lib.mkForce false;
            boot.lanzaboote.enable = true;
            boot.lanzaboote.pkiBundle = "/var/lib/sbctl";
          })
        ];
      };
      cobalt = mkSystem {
        hostname = "cobalt";
        users = [ "jml" ];
      };
      # `nix build .#nixosConfigurations.installIso.config.system.build.isoImage`
      # https://github.com/nix-community/nixos-generators
      installIso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ];
        specialArgs = {inherit inputs;};
      };
    }; 
    homeConfigurations = {
      "jml" = home-manager.lib.homeManagerConfiguration {
        modules = [
          ./users/jml/home.nix
        ];
      };
    };
  };
}
