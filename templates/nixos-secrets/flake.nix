{
  description = "nixos-secrets, the private part of zenware/nixos-config";
  inputs = {
    nixos-config.url = "github:zenware/nixos-config";
    nixpkgs.follows = "nixos-config/nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ nixos-config, nixpkgs, sops-nix, ... }:
  let
    pkgs = nixpkgs;
    mkSystem = nixos-config.lib.mkSystem;
  in
  {
    # TODO: Some massaging necessary on which hosts have secrets, and how their
    # private module structure works.
    nixosConfigurations = {
      lithium = mkSystem {
        hostname = "lithium";
        users = [
          "breakglass"
          "jml"
        ];
        extraModules = [
          sops-nix.nixosModules.sops
          { networking.domain = nixpkgs.lib.mkForce "example.com"; }
          ./modules/nixos/private-config
        ];
      };
    };
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        nixpkgs-fmt
        sops
      ];
    };
  };
}
