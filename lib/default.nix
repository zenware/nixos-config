{ nixpkgs, home-manager, inputs, ... }:
{
  # It's not really that I care about whether a system is a desktop system or
  # a server system, but moreso that I care about whether a system is headless or not.
  # I also care about things like if it's darwin, or wsl.
  mkSystem = {
    hostname,
    system ? "x86_64-linux",
    users ? [],
    extraModules ? []
  }:
  let
    hostModule = import ../hosts/${hostname} { inherit inputs; };
    userModules = map (name:
      import ../users/${name} {
        pkgs = nixpkgs.legacyPackages.${system};
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
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;
      };
    }) homeUserNames);
  in
    nixpkgs.lib.nixosSystem {
      inherit system;
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
    };
}
