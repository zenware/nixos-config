{ inputs, ... }:
{
  # NOTE: These are shared Home Manager module fragments, consumed by
  # NixOS/nix-darwin hosts via the integrated `home-manager.nixosModules` /
  # `darwinModules` module (see users/jml/default.nix). Home configuration is
  # applied as part of `nixos-rebuild switch` / `darwin-rebuild switch`;
  # there is no standalone `home-manager switch` target.
  flake.modules.homeManager.jml = {
    imports = [
      ../../users/jml/home
      inputs.nvf.homeManagerModules.default
    ];
  };
  flake.modules.homeManager.jml-desktop = ../../users/jml/home/desktop.nix;
  flake.modules.homeManager.jml-niri = ../../users/jml/home/niri.nix;
  flake.modules.homeManager.jml-linux-desktop = {
    imports = [
      ../../users/jml/home/noctalia.nix
      inputs.noctalia.homeModules.default
    ];
  };
}
