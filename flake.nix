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
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
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
      nix-darwin,
      ...
    }:
    let
      zwLib = import ./lib {
        inherit nixpkgs inputs;
      };
      mkSystem = zwLib.mkSystem;
      mkHomeModules = zwLib.mkHomeModules;

      # NOTE: Currently these are exclusively user-profiles which use home-manager.
      # Their home-manager specific declarations are at ../users/${username}/home.nix
      homeUserProfiles = {
        jml = {
          username = "jml";
          extraModules =
            { pkgs, lib, ... }:
            [
              nvf.homeManagerModules.default
              noctalia.homeModules.default
            ]
            ++ lib.optionals pkgs.stdenv.isLinux [ niri.homeModules.niri ];
        };
      };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      baseFlake = flake-parts.lib.mkFlake { inherit inputs; } (
        top@{
        ...
      }:
      let
        mkProfileExtraModules =
          profile:
          { pkgs, system }:
          if builtins.isFunction profile.extraModules then
            profile.extraModules {
              inherit pkgs system;
              lib = nixpkgs.lib;
            }
          else
            profile.extraModules or [ ];

        mkPerSystemHomeConfigs =
          system: pkgs:
          nixpkgs.lib.mapAttrs
            (_: profile:
              home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = mkHomeModules {
                  username = profile.username;
                  inherit pkgs;
                  extraModules = mkProfileExtraModules profile { inherit pkgs system; };
                };
              }
            )
            homeUserProfiles;
      in
      {
        imports = [
          inputs.flake-parts.flakeModules.modules
          inputs.home-manager.flakeModules.home-manager
          inputs.nix-topology.flakeModule
        ];
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
          darwinConfigurations = {
            m5mbp = nix-darwin.lib.darwinSystem {
              modules = [ ./hosts/m5mbp/configuration.nix ];
              specialArgs = { inherit inputs; };
            };
          };
          # For Debugging: `home-manager build --flake .` or `nix build .#homeConfigurations."jml".activationPackage`
          # `home-manager switch --flake .#jml`
          # https://nix-community.github.io/home-manager/options.xhtml
          templates = {
            secrets = {
              path = ./templates/nixos-secrets;
              description = "Templates for secrets management. These should be copied and filled out with real values, then encrypted with SOPS or a similar tool.";
            };
          };
          defaultTemplate = self.templates.secrets;
        };
        inherit systems;
        perSystem =
          { config, pkgs, system, ... }:
          let
            pkgsWithOverlays = import inputs.nixpkgs {
              inherit system;
              overlays = import ./overlays { inherit nixpkgs inputs; };
            };
          in
          {
            _module.args.pkgs = pkgsWithOverlays;
            legacyPackages.homeConfigurations = mkPerSystemHomeConfigs system pkgsWithOverlays;
            formatter = pkgsWithOverlays.nixfmt-tree;
            topology.modules = [
              ./topology
              {
                nixosConfigurations = nixpkgs.lib.filterAttrs (
                  name: _: name != "installIso"
                ) self.nixosConfigurations;
              }
            ];
          };
      }
      );
      homeConfigPackages = nixpkgs.lib.genAttrs systems (
        system: {
          homeConfigurations = baseFlake.legacyPackages.${system}.homeConfigurations;
        }
      );
    in
    baseFlake
    // {
      packages = nixpkgs.lib.recursiveUpdate (baseFlake.packages or { }) homeConfigPackages;
    };
}
