{
  # Is there any way of doing home-manager separately from nixosConfig/darwinConfig
  # and yet still reference the contents of the nixosConfig to decide whether to enable
  # noctalia-shell?
  # https://docs.noctalia.dev/getting-started/nixos/#config-ref
  programs.noctalia = {
    enable = true;
    settings.bar.main = {
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
}
