{ lib, pkgs, ... }:
let
  wallpaper = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/8957e93c95867faafec7f9988cedddd6837859fa/wallpapers/nix-wallpaper-binary-black.png";
    hash = "sha256-mhSh0wz2ntH/kri3PF5ZrFykjjdQLhmlIlDDGFQIYWw=";
  };
in
{
  # Is there any way of doing home-manager separately from nixosConfig/darwinConfig
  # and yet still reference the contents of the nixosConfig to decide whether to enable
  # noctalia-shell?
  # https://docs.noctalia.dev/getting-started/nixos/#config-ref
  #
  # NOTE: theme.* and wallpaper.default.path are set with `mkDefault` because
  # stylix's noctalia target (inputs.stylix.homeModules.stylix, wired in via
  # users/jml/default.nix) sets these same options with plain assignments
  # whenever stylix is enabled on a host. `mkDefault` lets stylix win there,
  # while still providing sane defaults on hosts without stylix.
  programs.noctalia = {
    enable = true;
    settings = {
      theme = lib.mkDefault {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
      wallpaper = {
        enabled = true;
        default.path = lib.mkDefault "${wallpaper}";
      };

      bar.main = {
        enabled = true;
        density = "compact";
        position = "right";

        capsule = false;
        start = [
          "network"
          "bluetooth"
        ];
        center = [ "workspaces" ];
        end = [
          "battery"
          "clock"
        ];
      };
    };
  };
}
