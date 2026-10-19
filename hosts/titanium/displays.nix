let
  mode = {
    width = 2560;
    height = 1440;
    refresh = 165.0;
  };
in
{
  # Hardware facts for Niri, applied to every Home Manager user on this host;
  # keybinds and rules live in users/jml/home/niri.nix.
  # Outputs are keyed by make/model/serial so they survive connector renumbering.
  home-manager.sharedModules = [
    {
      programs.niri.settings.outputs = {
        "Acer Technologies XB271HU #ASNPJuQhCSTd" = {
          inherit mode;
          position = {
            x = 0;
            y = 0;
          };
        };
        "Acer Technologies XB271HU #ASOG4ItaXund" = {
          inherit mode;
          position = {
            x = 2560;
            y = 0;
          };
        };
      };
    }
  ];
}
