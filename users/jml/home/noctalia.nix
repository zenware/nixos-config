{
  username,
  pkgs,
  lib,
  inputs,
  ...
}:
{


  # Is there any way of doing home-manager separately from nixosConfig/darwinConfig
  # and yet still reference the contents of the nixosConfig to decide whether to enable
  # noctalia-shell?
  # https://docs.noctalia.dev/getting-started/nixos/#config-ref
  programs.noctalia = {
    # Enable if linux
    enable = pkgs.stdenv.isLinux;
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
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
        center = ["workspaces"];
        end = [
          "battery"
          "clock"
        ];
      };
    };
  };

  # NOTE: Manually linking a niri config because my kludges have borked the
  # ability to conveniently use the niri-flake.
  home.file.".config/niri/config.kdl".source = ./niri/config.kdl;
  # programs.niri = {
  #   settings = {
  #     spawn-at-startup = [
  #       {
  #         command = [ "noctalia-shell" ];
  #       }
  #     ];
  #     # binds = with config.lib.niri.actions; {
  #     binds = with lib.niri.actions; {
  #       "Mod+Space".action.spawn = [
  #         "noctalia-shell" "ipc" "call" "launcher" "toggle"
  #       ];
  #     };
  #   };
  # };
}
