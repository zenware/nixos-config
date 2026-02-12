{
  nixpkgs,
  inputs ? null,
}:
let
  fixCmake =
    pkg:
    pkg.overrideAttrs (old: {
      cmakeFlakes = (old.cmakeFlags or [ ]) ++ [
        (nixpkgs.lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
      ];
    });
  cmake3Overlay =
    final: prev:
    nixpkgs.lib.mapAttrs
      (
        n: pkg:
        pkg.overrideAttrs (old: {
          cmakeFlags = old.cmakeFlags or [ ] ++ [
            (nixpkgs.lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
          ];
        })
      )
      {
        inherit (prev) hpipm;
      };
  libretroCmake3Overlay = final: prev: {
    libretro = prev.libretro // {
      thepowdertoy = prev.libretro.thepowdertoy.overrideAttrs (old: {
        cmakeFlags = old.cmakeFlags or [ ] ++ [
          (nixpkgs.lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
        ];
      });

      tic80 = prev.libretro.tic80.overrideAttrs (old: {
        cmakeFlags = old.cmakeFlags or [ ] ++ [
          (nixpkgs.lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
        ];
      });

      citra = prev.libretro.citra.overrideAttrs (old: {
        cmakeFlags = old.cmakeFlags or [ ] ++ [
          (nixpkgs.lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
        ];
      });

      dolphin = prev.libretro.dolphin.overrideAttrs (old: {
        cmakeFlags = old.cmakeFlags or [ ] ++ [
          (nixpkgs.lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
        ];
      });
    };
  };
  topologyOverlay =
    if inputs == null || !inputs ? nix-topology then null else inputs.nix-topology.overlays.default;
in
(
  [
    cmake3Overlay
    libretroCmake3Overlay
  ]
  ++ (nixpkgs.lib.optional (topologyOverlay != null) topologyOverlay)
)
