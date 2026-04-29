{
  description = "Configuration for NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.3";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
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

    # quickshell = {
    #   url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.quickshell.follows = "quickshell";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
    nix-topology.url = "github:oddlama/nix-topology";
    antigravity-nix.url = "github:jacopone/antigravity-nix";
    antigravity-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  # https://nix.dev/tutorials/nix-language.html#named-attribute-set-argument

  outputs =
    inputs@{
      flake-parts,
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      lanzaboote,
      disko,
      microvm,
      stylix,
      nvf,
      noctalia,
      niri,
      llm-agents,
      determinate,
      nix-topology,
      antigravity-nix,
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
          extraModules = [
            nvf.homeManagerModules.default
            noctalia.homeModules.default
            niri.homeModules.niri
            # Minor kludge to avoid wiring the packages through to `users/*/home/*.nix`
            { home.packages = [ antigravity-nix.packages.x86_64-linux.default ]; }
          ];
        };
      };
      pkgs = import nixpkgs {
        inherit system;
        overlays = import ./overlays { inherit nixpkgs inputs; };
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        config,
        withSystem,
        moduleWithSystem,
        ...
      }:
      {
        imports = [ ];
        flake = {
          lib = {
            mkSystem = mkSystem;
          };
          # NOTE: Run `nix flake show` to see what this flake has to offer.
          # TODO: Enable automated formatting with something like numtide/treefmt-nix
          nixosConfigurations = {
            titanium = mkSystem {
              hostname = "titanium";
              users = [
                "jml"
              ];
              extraModules = [
                #(import ./overlays)
                stylix.nixosModules.stylix
                niri.nixosModules.niri
                determinate.nixosModules.default
                microvm.nixosModules.host
              ];
            };
            lithium = mkSystem {
              hostname = "lithium";
              #specialArgs = {inherit inputs;};
              # NOTE: Rather than declare extraModules here, we override them in `nixos-secrets`
              #extraModules = [ microvm.nixosModules.host ];
              users = [
                "jml"
                "breakglass"
              ];
            };
            cobalt = mkSystem {
              hostname = "cobalt";
              users = [ "jml" ];
              extraModules = [
                stylix.nixosModules.stylix
                niri.nixosModules.niri
              ];
            };
            neon = mkSystem {
              hostname = "neon";
              users = [ "jml" ];
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
          formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
          topology = {
            ${system} = import nix-topology {
              inherit pkgs;
              modules = [
                ./topology
                {
                  nixosConfigurations = nixpkgs.lib.filterAttrs (
                    name: _: name != "installIso"
                  ) self.nixosConfigurations;
                }
              ];
            };
          };
          templates = {
            secrets = {
              path = ./templates/nixos-secrets;
              description = "Templates for secrets management. These should be copied and filled out with real values, then encrypted with SOPS or a similar tool.";
            };
          };
          defaultTemplate = self.templates.secrets;
        };
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];
        perSystem =
          { config, pkgs, ... }:
          {
            # Recommended: move all package definitions here.
            # e.g. (assuming you have a nixpkgs input)
            # packages.foo = pkgs.callPackage ./foo/package.nix {};
            # packages.bar = pkgs.callPackage ./bar/package.nix {
            #   foo = config.packages.foo;
            # };
          };
      }
    );
}
