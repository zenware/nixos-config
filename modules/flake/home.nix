{ inputs, ... }:
let
  zwLib = import ../../lib {
    inherit inputs;
    inherit (inputs) nixpkgs;
  };

  # NOTE: Currently these are exclusively user-profiles which use home-manager.
  # Their home-manager specific declarations are at ../../users/${username}/home.nix
  homeUserProfiles = {
    jml = {
      username = "jml";
      extraModules =
        { pkgs, lib, ... }:
        [
          inputs.nvf.homeManagerModules.default
          inputs.noctalia.homeModules.default
        ]
        ++ lib.optionals pkgs.stdenv.isLinux [ inputs.niri.homeModules.niri ];
    };
  };

  mkProfileExtraModules =
    profile:
    { pkgs, system }:
    if builtins.isFunction profile.extraModules then
      profile.extraModules {
        inherit pkgs system;
        lib = inputs.nixpkgs.lib;
      }
    else
      profile.extraModules or [ ];
in
{
  # For Debugging: `home-manager build --flake .` or `nix build .#homeConfigurations."jml".activationPackage`
  # `home-manager switch --flake .#jml`
  # https://nix-community.github.io/home-manager/options.xhtml
  perSystem =
    { pkgs, system, ... }:
    {
      legacyPackages.homeConfigurations = inputs.nixpkgs.lib.mapAttrs (
        _: profile:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = zwLib.mkHomeModules {
            username = profile.username;
            inherit pkgs;
            extraModules = mkProfileExtraModules profile { inherit pkgs system; };
          };
        }
      ) homeUserProfiles;
    };
}
