{ config, inputs, ... }:
let
  inherit (config.flake.lib) mkSystem;
in
{
  # NOTE: Run `nix flake show` to see what this flake has to offer.
  # TODO: Enable automated formatting with something like numtide/treefmt-nix
  flake.nixosConfigurations = {
    titanium = mkSystem {
      hostname = "titanium";
      users = [
        "jml"
      ];
      extraModules = [
        #(import ../../overlays)
        inputs.stylix.nixosModules.stylix
        inputs.niri.nixosModules.niri
        inputs.determinate.nixosModules.default
        inputs.microvm.nixosModules.host
      ];
    };
    lithium = mkSystem {
      hostname = "lithium";
      #specialArgs = {inherit inputs;};
      # NOTE: Rather than declare extraModules here, we override them in `nixos-secrets`
      #extraModules = [ inputs.microvm.nixosModules.host ];
      users = [
        "jml"
        "breakglass"
      ];
    };
    cobalt = mkSystem {
      hostname = "cobalt";
      users = [ "jml" ];
      extraModules = [
        inputs.stylix.nixosModules.stylix
        inputs.niri.nixosModules.niri
      ];
    };
    neon = mkSystem {
      hostname = "neon";
      users = [ "jml" ];
    };
    # `nix build .#nixosConfigurations.installIso.config.system.build.isoImage`
    # https://github.com/nix-community/nixos-generators
    installIso = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ];
      specialArgs = { inherit inputs; };
    };
  };

  # NOTE: m5mbp is as much a host machine as the rest; it just boots darwin,
  # so it lives under darwinConfigurations instead of nixosConfigurations.
  flake.darwinConfigurations = {
    m5mbp = inputs.nix-darwin.lib.darwinSystem {
      modules = [ ../../hosts/m5mbp/configuration.nix ];
      specialArgs = { inherit inputs; };
    };
  };
}
