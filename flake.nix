{
  description = "Configuration for NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
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

    # quickshell = {
    #   url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.quickshell.follows = "quickshell";
    };

    # niri = {
    #   url = "github:sodiboo/niri-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    llm-agents.url = "github:numtide/llm-agents.nix";
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
      noctalia,
      #niri,
      llm-agents,
      determinate,
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
            #niri.homeModules.niri
          ];
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
        titanium = mkSystem {
          hostname = "titanium";
          users = [
            "jml"
          ];
          extraModules = [
            #(import ./overlays)
            stylix.nixosModules.stylix
            #niri.nixosModules.niri
            determinate.nixosModules.default
          ];
        };
        lithium = mkSystem {
          hostname = "lithium";
          # extraModules = [ inputs.sops-nix.nixosModules.sops ];
          users = [
            "jml"
            "breakglass"
          ];
        };
        cobalt = mkSystem {
          hostname = "cobalt";
          users = [ "jml" ];
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
    };
}
