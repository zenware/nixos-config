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

    #obsidian-nvim.url = "github:epwalsh/obsidian.nvim";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
      #inputs.obsidian-nvim.follows = "obsidian-nvim";
    };

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };
  };
  # https://nix.dev/tutorials/nix-language.html#named-attribute-set-argument
  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      sops-nix,
      lanzaboote,
      disko,
      stylix,
      nvf,
      ...
    }:
    let
      zwLib = import ./lib {
        inherit nixpkgs home-manager inputs;
      };
      mkSystem = zwLib.mkSystem;
      mkHome = zwLib.mkHome;
      mkHomeConfigs = zwLib.mkHomeConfigs;

      # NOTE: Currently these are exclusively user-profiles which use home-manager.
      # Their home-manager specific declarations are at ../users/${username}/home.nix
      system = "x86_64-linux"; # TODO: Improve this from only static x86 to dynamic.
      homeUserProfiles = {
        jml = mkHome {
          inherit system; # inputs;
          username = "jml";
          extraModules = [ nvf.homeManagerModules.default ];
        };
      };
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
          homeUsers = {
            jml = homeUserProfiles.jml.module;
          };
          #extraModules = [ (import ./overlays) ];
          # NOTE: If I'm using a home-manager configuration on a given host,
          # I also need to include the relevant modules.
          # TODO: Can I instead self-reference the homeConfigurations in this flake?
          extraModules = [
            stylix.nixosModules.stylix
          ];
        };
        # `nix build .#nixosConfigurations.installIso.config.system.build.isoImage`
        # https://github.com/nix-community/nixos-generators
        installIso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ];
          specialArgs = { inherit inputs; };
        };
      };

      # For Debugging: `home-manager build --flake .` or `nix build .#homeConfigurations."jml".activationPackage`
      # `home-manager switch --flake .#jml`
      # https://nix-community.github.io/home-manager/options.xhtml
      homeConfigurations = mkHomeConfigs homeUserProfiles;
    };
}
