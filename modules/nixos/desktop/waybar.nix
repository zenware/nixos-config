{ pkgs, ... }:
{
  programs.waybar = {
    #enable = true;
    #systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        height = 24;

        modules-left = [
          "network#wifi"
          "network#ethernet"
        ];

        modules-center = [
          "niri/window"
        ];

        modules-right = [
          "disk"
          "memory"
          "cpu"
          "temperature"
          "pulseaudio"
          "clock"
          "tray"
        ];

        "tray" = {
          spacing = 5;
          icon-size = 24;
        };

        "niri/window" = {
          format = "{}";
          max-length = 80;
        };

        "network#wifi" = {
          interface = "wlp3s0";
          format-disconnected = "";
          tooltip-format = "{ifname} via {gwaddr}";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };

        "network#ethernet" = {
          interface = "enp4s0";
          format-disconnected = "";
          tooltip-format = "{ifname} via {gwaddr}";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };

        disk = {
          interval = 120;
          format = "{free}";
          path = "/";
        };
        memory = {
          interval = 5;
          format = "{}%";
        };
        cpu = {
          interval = 2;
          format = "{usage}% ({avg_frequency}GHz)";
        };
        # TODO: Write a udevadm rule for the zenpower Tdie
        temperature = {
          interval = 20;
          format = "{temperatureC}°C";
          hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
        };
      };
    };
  };
}
