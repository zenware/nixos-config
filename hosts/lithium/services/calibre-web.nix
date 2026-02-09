{ inputs, config, pkgs, lib, ... }:
let
  homelabDomain = config.networking.domain;
  #certDir = config.security.acme.certs."${homelabDomain}".directory;
  svcDomain = "books.${homelabDomain}";
  svcHttpPort = config.services.calibre-web.listen.port;
  web_data_dir = "calibre-web";
  # TODO: I want the actual media stored in the tank.
  library_path = "/tank/media/library/books";
  #library_path = "/var/lib/calibre-library";
in
{
  # TODO: This isn't the right place for this, but we need to guarantee that a
  # media group exists.
  users.users.calibre-web.extraGroups = [ "media" ];
  users.groups.media = {};

  services.caddy.virtualHosts."${svcDomain}".extraConfig = ''
    reverse_proxy localhost:8883
  '';

    # reverse_proxy :${toString svcHttpPort}
  #   encode {
  #     zstd
  #     gzip
  #     minimum_length 1024
  #   }
  # '';

  # NOTE: Needs some manual setup in Web-UI and I ecountered issues connecting even with firewall enabled.
  # The following command is what I used to forward the port:
  # ssh -f -N -L localhost:8883:localhost:8883 jml@lithium
  services.calibre-web = {
    enable = true;
    listen.port = 8883;
    # NOTE: Don't need to open calibre-web port, it's served by reverse_proxy
    openFirewall = true;  # TODO: Temporarily opened to allow configuration from inside my network.

    user = "calibre-web";
    group = "calibre-web";

    # Either absolute path or directory name under "/var/lib"
    # /tank/media/library/books
    dataDir = web_data_dir;

    options = {
      enableBookUploading = true;
      enableBookConversion = true;
      # NOTE: If I don't already have an extant calibreLibrary, I need to leave this null or the app won't launch.
      calibreLibrary = library_path;
    };
  };
}
