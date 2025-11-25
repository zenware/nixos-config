{
  nixpkgs,
  home-manager,
  inputs,
  ...
}:
let
  allOverlays = import (../overlays) { inherit nixpkgs; };
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
      homeUsers ? { },
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

      formattedHomeUsers = nixpkgs.lib.mapAttrs (username: moduleList: {
        imports = moduleList;
      }) homeUsers;
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        hostModule
      ]
      ++ userModules
      ++ extraModules
      ++ (
        if homeUsers != { } then
          [
            home-manager.nixosModules.home-manager
            {
              #home-manager.useGlobalPkgs = true;  # NOTE: Incompatible with nixpkgs.{config,overlays}
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-bak";

              # Directly inject the module lists? (isn't this the problem?)
              home-manager.users = formattedHomeUsers;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ]
        else
          [ ]
      );
      specialArgs = {
        inherit inputs hostname;
      }
      // extraSpecialArgs;
    };

  getUserHomeModule =
    username: pkgs: inputs:
    import ../users/${username}/home.nix {
      inherit username pkgs inputs;
      lib = nixpkgs.lib;
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
