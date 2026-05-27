{
  nixpkgs,
  inputs,
  ...
}:
let
  allOverlays = import (../overlays) { inherit nixpkgs inputs; };
in
{
  mkSystem =
    {
      hostname,
      system ? "x86_64-linux",
      users ? [ ],
      extraModules ? [ ],
      extraSpecialArgs ? { },
    }:
    let
      pkgs_with_overlays = import nixpkgs {
        inherit system;
        overlays = allOverlays;
      };
      hostModule = import ../hosts/${hostname} {
        inherit inputs;
        pkgs = pkgs_with_overlays;
      };
      userModules = map (
        name:
        import ../users/${name} {
          pkgs = pkgs_with_overlays;
          lib = nixpkgs.lib;
        }
      ) users;
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        hostModule
      ]
      ++ userModules
      ++ extraModules
      ++ (if inputs ? nix-topology then [ inputs.nix-topology.nixosModules.default ] else [ ]);
      specialArgs = {
        inherit inputs hostname;
      }
      // extraSpecialArgs;
    };

  mkHomeModules =
    {
      username,
      pkgs,
      extraModules ? [ ],
    }:
    [
      (import ../users/${username}/home {
        inherit inputs username pkgs;
        lib = nixpkgs.lib;
      })
    ]
    ++ extraModules;
}
