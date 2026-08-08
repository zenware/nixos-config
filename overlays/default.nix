{ nixpkgs, inputs }:
let
  fixCmake =
    pkg:
    pkg.overrideAttrs (old: {
      cmakeFlakes = (old.cmakeFlags or [ ]) ++ [
        (nixpkgs.lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
      ];
    });
  cheetah3Overlay = final: prev: {
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (_pythonFinal: pythonPrev: {
        cheetah3 = pythonPrev.cheetah3.overrideAttrs {
          # The upstream distribution is named "ct3"; "cheetah3" is only
          # the Nix package attribute and repository name.
          pname = "ct3";
        };
      })
    ];
  };
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
in
([
  cheetah3Overlay
  cmake3Overlay
  libretroCmake3Overlay
  inputs.flux.overlays.default
  inputs.nix-topology.overlays.default
])
