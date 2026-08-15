{ config, lib, ... }:
let
  homelabDomain = config.zw.homelab.domain;
  svcDomain = "paperless.${homelabDomain}";
  svcPort = config.zw.servicePorts.tcp.paperless;
  dataDir = "/tank/services/paperless";
  mediaDir = "/tank/shares/documents";
  consumptionDir = "${mediaDir}/consume";
  paperlessUnits = [
    "paperless-scheduler"
    "paperless-web"
    "paperless-consumer"
    "paperless-task-queue"
  ];
in
{
  services.caddy.virtualHosts."*.${homelabDomain}".extraConfig = ''
    @paperless host ${svcDomain}
    handle @paperless {
      reverse_proxy 127.0.0.1:${toString svcPort}
    }
  '';

  systemd.tmpfiles.rules = [
    "d /tank/services 0755 root root -"
    "d ${dataDir} 0750 paperless paperless -"
    "d ${mediaDir} 0750 paperless paperless -"
    "d ${consumptionDir} 0770 paperless paperless -"
  ];

  users.users.paperless.extraGroups = [ "users" ];
  systemd.services = lib.genAttrs paperlessUnits (_: {
    serviceConfig.SupplementaryGroups = lib.mkForce [
      "redis-paperless"
      "users"
    ];
  });

  services.paperless = {
    enable = true;
    inherit dataDir mediaDir consumptionDir;
    address = "127.0.0.1";
    port = svcPort;
    domain = svcDomain;
    database.createLocally = true;
    settings = {
      PAPERLESS_ADMIN_USER = "admin";
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE"
        "desktop.ini"
      ];
      PAPERLESS_OCR_LANGUAGE = "eng";
    };
  };
}
