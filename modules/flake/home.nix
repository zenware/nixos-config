{ config, inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  zwLib = import ../../lib {
    inherit inputs;
    inherit (inputs) nixpkgs;
  };

  standaloneProfiles = {
    # Standalone Linux desktop profile.
    jml = {
      system = "x86_64-linux";
      isDesktop = true;
    };
    jml-headless = {
      system = "x86_64-linux";
      isDesktop = false;
    };
    jml-darwin = {
      system = "aarch64-darwin";
      isDesktop = true;
    };
  };

  mkHomeConfiguration =
    {
      system,
      isDesktop,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = zwLib.mkPkgs system;
      extraSpecialArgs = {
        inherit inputs;
        username = "jml";
      };
      modules = [
        config.flake.modules.homeManager.jml
      ]
      ++ lib.optional isDesktop config.flake.modules.homeManager.jml-desktop
      ++ lib.optional (
        isDesktop && lib.hasSuffix "-linux" system
      ) config.flake.modules.homeManager.jml-linux-desktop-standalone;
    };
in
{
  flake.modules.homeManager.jml = {
    imports = [
      ../../users/jml/home
      inputs.nvf.homeManagerModules.default
    ];
  };
  flake.modules.homeManager.jml-desktop = ../../users/jml/home/desktop.nix;
  flake.modules.homeManager.jml-linux-desktop = {
    imports = [
      ../../users/jml/home/noctalia.nix
      inputs.noctalia.homeModules.default
    ];
  };
  flake.modules.homeManager.jml-linux-desktop-standalone = {
    imports = [
      ../../users/jml/home/niri-standalone.nix
      ../../users/jml/home/noctalia-standalone.nix
      config.flake.modules.homeManager.jml-linux-desktop
    ];
  };

  # Standalone targets:
  # `home-manager switch --flake .#jml`
  # `home-manager switch --flake .#jml-headless`
  # `home-manager switch --flake .#jml-darwin`
  # https://nix-community.github.io/home-manager/options.xhtml
  flake.homeConfigurations = lib.mapAttrs (_: mkHomeConfiguration) standaloneProfiles;
}
