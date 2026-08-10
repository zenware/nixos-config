{
  nixpkgs,
  inputs,
  sharedModules ? [ ],
  sharedHomeModules ? { },
  ...
}:
let
  allOverlays = import (../overlays) { inherit nixpkgs inputs; };
  mkPkgs =
    system:
    import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = allOverlays;
    };
in
{
  inherit mkPkgs;

  mkSystem =
    {
      hostname,
      system ? "x86_64-linux",
      users ? [ ],
      extraModules ? [ ],
      extraSpecialArgs ? { },
    }:
    let
      pkgs_with_overlays = mkPkgs system;
      hostModule = import ../hosts/${hostname} {
        inherit inputs;
        pkgs = pkgs_with_overlays;
      };
      userModules = map (name: import ../users/${name}) users;
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        { nixpkgs.overlays = allOverlays; }
        inputs.home-manager.nixosModules.home-manager
        hostModule
      ]
      ++ sharedModules
      ++ userModules
      ++ extraModules
      ++ (if inputs ? nix-topology then [ inputs.nix-topology.nixosModules.default ] else [ ]);
      specialArgs = {
        inherit inputs hostname;
        homeManagerModules = sharedHomeModules;
      }
      // extraSpecialArgs;
    };
}
