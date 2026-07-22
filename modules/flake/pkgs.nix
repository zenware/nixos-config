{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgsWithOverlays = import inputs.nixpkgs {
        inherit system;
        overlays = import ../../overlays {
          inherit inputs;
          inherit (inputs) nixpkgs;
        };
      };
    in
    {
      _module.args.pkgs = pkgsWithOverlays;
      formatter = pkgsWithOverlays.nixfmt-tree;
    };
}
