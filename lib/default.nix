{ nixpkgs, home-manager, inputs, ... }:
let
  allOverlays = import (../overlays) { inherit nixpkgs; };
in
{
  # It's not really that I care about whether a system is a desktop system or
  # a server system, but moreso that I care about whether a system is headless or not.
  # I also care about things like if it's darwin, or wsl.
  # TODO: Expand this to actually make use of extraSpecialArgs and pass special
  # args to the relevant places.
  mkSystem = {
    hostname,
    system ? "x86_64-linux",
    users ? [],
    extraModules ? [],
    extraSpecialArgs ? {}
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
    userModules = map (name:
      import ../users/${name} {
        pkgs = pkgs_with_overlays;
        lib = nixpkgs.lib;
      }
    ) users;

    homeUserNames = builtins.filter (name:
      builtins.pathExists ../users/${name}/home.nix
    ) users;

    homeUsers = nixpkgs.lib.listToAttrs (map (name: {
      name = name;
      value = import ../users/${name}/home.nix {
        username = name;
        pkgs = pkgs_with_overlays;
        lib = nixpkgs.lib;
      };
    }) homeUserNames);
  in
    nixpkgs.lib.nixosSystem {
      inherit system;
      # pkgs = import inputs.nixpkgs {
      #   inherit system;
      #   overlays = allOverlays;
      #   config = { allowUnfree = true; nvidia.acceptLicense = true; };
      # };
      modules = [ hostModule ]
        ++ userModules
        ++ extraModules
        ++ (if homeUserNames != [] then [
          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "hm-bak";
            home-manager.users = homeUsers;
          }
        ] else []);
      specialArgs = {
        inherit inputs hostname;
      } // extraSpecialArgs;
    };
}
