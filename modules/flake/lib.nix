{ config, inputs, ... }:
let
  zwLib = import ../../lib {
    inherit inputs;
    inherit (inputs) nixpkgs;
    # NOTE: The dendritic seam — every flake.modules.nixos.* module is
    # imported into every mkSystem host (public and nixos-secrets alike),
    # so hosts opt in/out via the options those modules declare.
    sharedModules = builtins.attrValues config.flake.modules.nixos;
    sharedHomeModules = config.flake.modules.homeManager;
  };
in
{
  flake.lib = {
    inherit (zwLib) mkSystem;
  };
}
