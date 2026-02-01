{ config, lib, ... }:
let
  inherit (config.lib.topology) mkInternet mkRouter mkSwitch mkConnection;
in
{
  # Which clients actually matter for the purposes of documenting my homelab?
  # titanium (main desktop)
  # lithium (home server)
  # router(s)
  # jetkvm (backup access to lithium)
  # practically, everything else is just some user/IoT DHCP client and doesn't need to be documented here.
  # TODO: Keep poking at this: https://oddlama.github.io/nix-topology/topology-options.html
  # This serves devices in my residential home network.
  networks.home = {
    #info = ".home.arpa";
    name = "home net";
    cidrv4 = "192.168.50.0/24";
    icon = "interfaces.wifi";
    # TODO: Add cidrv6?
  };

  # Connects "protected" services on lithium to other clients on the tailnet.
  networks.tailnet = {
    name = "tailnet";
    cidrv6 = "fd7a:115c:a1e0::/48";
  };

  # TODO: Add Tailnet.

  # WAN
  # Auto IP
  # NAT
  # UPnP
  # Forward Local Domain Queries to Upstream DNS?
  # WAN DNS Currently = 8.8.8.8, 8.8.4.4
  # TODO: Switch this to a lithium DNS at 192.168.50.3
  nodes.internet = mkInternet {
    connections = mkConnection "hydrogen" "2.5G/1G WAN";
  };

  # Primary Home Router
  # DHCP/DNS server for network
  # domain name: home.arpa
  # IP Pool Starting Address - 192.168.50.2
  # IP Pool Ending Address - 192.168.50.254
  # Lease Time - 86400 seconds (1 day)
  # DNS Server 1 - 192.168.50.1
  # DNS Server 2 -
  # IPv6 DNS Server - 
  # Advertise router's IP in addition to user-specified DNS
  # WINS Server - 
  # DHCP Reservation Table
  # - lithium, D8:5E:D3:0E:BC:89, 192.168.50.3
  # - neon, 70:A8:D3:98:C4:93, 192.168.50.10 -- Maybe I shouldn't care about DHCP reservations for wireless clients...
  # has interfaces LAN, MAN, WAN in the WebUI
  # https://www.asus.com/us/networking-iot-servers/whole-home-mesh-wifi-system/zenwifi-wifi-systems/asus-zenwifi-et8/
  # https://www.asus.com/us/networking-iot-servers/whole-home-mesh-wifi-system/zenwifi-wifi-systems/asus-zenwifi-et8/techspec/
  # Currently running wireless backhaul because it's faster (although less stable) than wired backhaul
  # ssh zenware@hydrogen -p 2222
  # Port Forwarding for, Valheim, Satisfactory, Caddy, VRising, Palworld, Git-SSH (Remove this one ASAP, and depend on Tailscale instead?)
  # DDNS on the router vs DDNS on Lithium?
  # WAN -> NAT Passthrough for different kinds of VPNs and FTP ALG. Should I actually enable these or no? Under what conditions should I enable each one?
  # PPTP, L2TP, IPSec, RTSP, H.323, SIP, PPPoE
  # Jumbo Frames? Yes or No? - No Point in doing Jumbo Frames over 1G link, wait until actually 2.5G or 10G.
  nodes.hydrogen = mkRouter "Primary AiMesh Router - Front Room"{
    info = "Asus ZenWiFi ET8";
    image = ./images/ZenWiFi_ET8.png;
    deviceType = "router";
    # Names of the interfaces as they read on the physical device.
    # Additionally, made up names for the WiFi interfaces... WLAN2.4GHz, WLAN5GHz, WLAN6GHz
    interfaceGroups = [["LAN3" "LAN2"  "LAN1"  "2.5G/1G WAN"] ["WLAN2.4GHz" "WLAN5GHz" "WLAN6GHz"]];
    #connections."2.5G/1G WAN" = mkConnection "internet" "2.5G/1G WAN";
    # titanium is wired into the primary router (front room)
    connections.LAN1 = mkConnection "titanium" "LAN1";
    # backhaul to the AiMesh node (helium) over 6GHz
    connections.WLAN6GHz = mkConnection "helium" "WLAN6GHz";
    #cidrv4 = "192.168.50.1/24";
  };
  
  # MAC Address: FC:34:97:DB:1D:60
  nodes.helium = mkRouter "AiMesh Node - Back Room" {
    info = "Asus ZenWiFi ET8";
    image = ./images/ZenWiFi_ET8.png;
    deviceType = "router";
    interfaceGroups = [["LAN3" "LAN2"  "LAN1"  "WAN"] ["WLAN2.4GHz" "WLAN5GHz" "WLAN6GHz"]];
    #cidr = "";
    # Wireless backhaul on 6GHz band to the primary router
    connections.WLAN6GHz = mkConnection "hydrogen" "WLAN6GHz";
    # Lithium (home server) is physically plugged into this AiMesh node on LAN1 and LAN2
    connections.LAN1 = mkConnection "lithium" "LAN1";
    connections.LAN2 = mkConnection "lithium" "LAN2";
    # JetKVM attached to LAN3 for remote KVM access to Lithium
    connections.LAN3 = mkConnection "jetkvm" "LAN3";
  };



  # This switch isn't real but I do have a Real Switch.
  nodes.switch1 = mkSwitch "Switch 1" {
    info = "D-Link DGS-105";
    image = ./images/image-dlink-dgs105.png;
    interfaceGroups = [["eth1" "eth2" "eth3" "eth4" "eth5"]];
    connections.eth1 = mkConnection "host1" "lan";
    connections.eth2 = [(mkConnection "host2" "wan") (mkConnection "host3" "eth0")];

    # any other attributes specified here are directly forwarded to the node:
    interfaces.eth1.network = "home";
  };

  nodes.node1 = {
    deviceType = "router";
    interfaces.interface1.network = "home";
  };

  # Home server: lithium
  # supposed to be a bonded connection over two NICs to the AiMesh node
  nodes.lithium = {
    name = "lithium";
    #deviceType = lib.mkDefault "server";
    # DHCP reservation on home net: 192.168.50.3
    #hardware.mac = "D8:5E:D3:0E:BC:89";
    interfaces.LAN1.network = "home"; # connected to AiMesh node LAN1
    #interfaces.LAN1.address = "192.168.50.3";
    interfaces.LAN2.network = "home"; # second physical NIC to AiMesh node LAN2
    # Tailscale virtual interface connecting lithium to the tailnet
    interfaces.tailscale.network = "tailnet";
    #info = "Home server (services)";
  };

  # JetKVM device attached to AiMesh node LAN3 for remote HDMI/USB KVM access
  nodes.jetkvm = {
    name = "JetKVM";
    deviceType = "device";
    #hardware.mac = "44:B7:D0:E6:40:2C";
    interfaces.LAN3.network = "home";
    #interfaces.LAN3.address = "192.168.50.2";
    #info = "JetKVM remote management (HDMI + USB/HID to lithium)";
  };

  # Desktop: titanium (wired into the primary AiMesh router)
  nodes.titanium = {
    name = "titanium";
    #deviceType = "device";
    interfaces.LAN1.network = "home";
    #info = "Main desktop - plugged into Primary AiMesh Router (Front Room)";
  };

  nodes.host1 = {
    deviceType = "device";
    interfaces.lan.network = "home";
  };
  nodes.host2 = {
    deviceType = "device";
    interfaces.wan.network = "home";
  };
  nodes.host3 = {
    deviceType = "device";
    interfaces.eth0.network = "home";
  };

  nodes.toaster = {
    name = "My Toaster";
    deviceType = "device";
    hardware.info = "Raspberry Pi Zero W";
  };
}