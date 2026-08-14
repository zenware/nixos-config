{ config, lib, ... }:
let
  duplicateAssignments =
    protocol:
    let
      assignments = lib.mapAttrsToList (name: port: {
        inherit name port;
      }) config.zw.servicePorts.${protocol};
      uniquePorts = lib.unique (map (assignment: assignment.port) assignments);
    in
    map
      (
        port:
        "${protocol}/${toString port} (${
          lib.concatStringsSep ", " (
            map (assignment: assignment.name) (lib.filter (assignment: assignment.port == port) assignments)
          )
        })"
      )
      (
        lib.filter (
          port: lib.length (lib.filter (assignment: assignment.port == port) assignments) > 1
        ) uniquePorts
      );

  duplicates = duplicateAssignments "tcp" ++ duplicateAssignments "udp";
in
{
  options.zw.servicePorts = lib.mkOption {
    type = lib.types.submodule {
      options = {
        tcp = lib.mkOption {
          type = lib.types.attrsOf lib.types.port;
          default = {
            adguardDns = 53;
            caddyHttp = 80;
            caddyHttps = 443;
            sambaNetbiosSession = 139;
            sambaSmb = 445;
            forgejo = 3000;
            grafana = 3001;
            uptimeKuma = 3002;
            immichMachineLearning = 3003;
            adguardHome = 3004;
            kanidmLdap = 3636;
            seerr = 5055;
            sambaWsdd = 5357;
            radarr = 7878;
            sabnzbd = 8080;
            miniflux = 8081;
            qbittorrent = 8082;
            nextcloudBackend = 8083;
            jellyfinHttp = 8096;
            jellyfinHttps = 8920;
            homeAssistant = 8123;
            flaresolverr = 8191;
            vaultwarden = 8222;
            syncthingGui = 8384;
            kanidmHttps = 8443;
            lidarr = 8686;
            readarr = 8787;
            calibreWeb = 8883;
            sonarr = 8989;
            hermesWebhook = 8644;
            hermesDashboard = 9119;
            prowlarr = 9696;
            hermesWebui = 18787;
            syncthingTransfer = 22000;
            palworldRcon = 25575;
            immich = 2283;
            paperless = 28981;
          };
        };

        udp = lib.mkOption {
          type = lib.types.attrsOf lib.types.port;
          default = {
            adguardDns = 53;
            sambaNetbiosNs = 137;
            sambaNetbiosDgm = 138;
            sambaWsdd = 3702;
            jellyfinSsdp = 1900;
            jellyfinClientDiscovery = 7359;
            palworldGame = 8211;
            syncthingDiscovery = 21027;
            syncthingTransfer = 22000;
            palworldQuery = 27015;
          };
        };
      };
    };
    default = { };
    description = "TCP and UDP listener ports used by services on lithium.";
  };

  config.assertions = [
    {
      assertion = duplicates == [ ];
      message = "Duplicate lithium service port assignments: ${lib.concatStringsSep "; " duplicates}";
    }
  ];
}
