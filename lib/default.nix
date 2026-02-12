{
  nixpkgs,
  home-manager,
  inputs,
  ...
}:
let
  allOverlays = import (../overlays) { inherit nixpkgs inputs; };
  getPkgs =
    system:
    import nixpkgs {
      inherit system;
      overlays = allOverlays;
    };
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

  /**
    This function returns an attribute set { module, config }.
  */
  mkHome =
    {
      username,
      system ? "x86_64-linux",
      extraModules ? [ ],
    }:
    let
      pkgs_with_overlays = getPkgs system;
      moduleList = [
        (import ../users/${username}/home.nix {
          inherit inputs username;
          pkgs = pkgs_with_overlays;
          lib = nixpkgs.lib;
        })
      ]
      ++ extraModules;
    in
    {
      module = moduleList;
      config = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs_with_overlays;
        modules = moduleList;
      };
    };

  mkHomeConfigs = userProfiles: nixpkgs.lib.mapAttrs (username: profile: profile.config) userProfiles;
}
