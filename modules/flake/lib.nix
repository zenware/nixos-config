{ inputs, ... }:
let
  zwLib = import ../../lib {
    inherit inputs;
    inherit (inputs) nixpkgs;
  };
in
{
  flake.lib = {
    inherit (zwLib) mkSystem;
  };
}
