{ config, lib, ... }:
let
  inherit (config.lib.topology) mkInternet mkRouter mkSwitch mkConnection;
in
{
  networks.home = {
    name = "home net";
    cidrv4 = "192.168.50.0/24";
    icon = "interfaces.wifi";
  };

  networks.tailnet = {
    name = "tailnet";
    cidrv6 = "fd7a:115c:a1e0::/48";
  };

  nodes.internet = mkInternet {
    connections = mkConnection "hydrogen" "2.5G/1G WAN";
  };

  nodes.hydrogen = mkRouter "Primary AiMesh Router" {
    info = "Asus ZenWiFi ET8";
    image = ./images/ZenWiFi_ET8.png;
    deviceType = "router";
    interfaceGroups = [["LAN3" "LAN2"  "LAN1"  "2.5G/1G WAN"] ["WLAN2.4GHz" "WLAN5GHz" "WLAN6GHz"]];
    connections.LAN1 = mkConnection "titanium" "LAN1";
    connections.WLAN6GHz = mkConnection "helium" "WLAN6GHz";
  };

  nodes.helium = mkRouter "AiMesh Node" {
    info = "Asus ZenWiFi ET8";
    image = ./images/ZenWiFi_ET8.png;
    deviceType = "router";
    interfaceGroups = [["LAN3" "LAN2"  "LAN1"  "WAN"] ["WLAN2.4GHz" "WLAN5GHz" "WLAN6GHz"]];
    connections.WLAN6GHz = mkConnection "hydrogen" "WLAN6GHz";
    connections.LAN1 = mkConnection "lithium" "LAN1";
    connections.LAN2 = mkConnection "lithium" "LAN2";
    connections.LAN3 = mkConnection "jetkvm" "LAN3";
  };

  nodes.lithium = {
    name = "lithium";
    interfaces.LAN1.network = "home";
    interfaces.LAN2.network = "home";
    interfaces.tailscale.network = "tailnet";
  };

  nodes.jetkvm = {
    name = "JetKVM";
    deviceType = "device";
    interfaces.LAN3.network = "home";
  };

  nodes.titanium = {
    name = "titanium";
    interfaces.LAN1.network = "home";
  };
}