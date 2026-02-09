{ inputs, config, pkgs, lib, ... }:
let
  svcDomain = "photos.${config.networking.domain}";
  immichMediaDir = "/tank/shares/immich-media";
  svcPort = config.services.immich.port;
  # https://docs.immich.app/install/config-file/
  jsonSettings = {
    server.externalDomain = "https://${svcDomain}";
    # TODOL: Get this working without OAuth/OICD first, and then add it later...
    # oauth = {
    #   enabled = true;
    #   issuerUrl = "https://";  # TODO: the kanidm url?
    #   clientId = "immich";
    #   # NOTE: Why config.sops.placeholder was originally?
    #   clientSecret = config.sops.secrets."immich/oauth2_client_secret".path;
    #   scope = "openid email profile";
    #   signingAlgorithm = "ES256";
    #   storageLabelClaim = "email";
    #   buttonText = "Login with Kanidm";
    #   autoLaunch = true;
    #   mobileOverrideEnabled = true;
    #   mobileRedirectUri = "https://${svcDomain}/api/oauth/mobile-redirect/";
    # };
  };
in
{

  config = {
    # NOTE: The following repo contains a highly mature immich setup on nixos.
    # https://github.com/xinyangli/nixos-config/blob/a8b5bea68caea573801ccfdb8ceacb7a8f2b0190/machines/agate/services/immich.nix
    services.caddy.virtualHosts."${svcDomain}".extraConfig = ''
      reverse_proxy [::1]:${toString svcPort}
    '';

    # NOTE: Primarily to contain DB_PASSWORD to make it possible to backup and restore the DB.
    # sops.secrets.immich_env = {
    #   sopsFile = ../../secrets/immich.env;
    #   format = "dotenv";
    #   mode = "0440";
    #   owner = "immich";
    #   group = "immich";
    #   restartUnits = [ "immich.service" ];
    # };
    # TODO: The block below this needs uncommented.

    # TODO: Set file permissions and ensure a path exists to store photos on `tank`

    users.users.immich = {
      isSystemUser = true;
    };
    users.groups.immich = {};
    # NOTE: the users group gets us into /mnt/shares
    users.users.immich.extraGroups = [ "video" "render" "media" "users" ];
    # TODO: There may be a slightly more nixy way of doing this tmpfiles rule.
    # https://github.com/nixos-bsd/nixbsd/blob/e393e147e3c30f6424c2a32c5362241c004b5156/modules/services/web-apps/immich.nix#L293C14-L293C27
    # systemd.tmpfiles.rules = [
    #   "d ${immichMediaDir} 0770 immich immich -"
    # ];

    # TODO: Setup mTLS for external / non-tailscale VPN immich access.
    # https://github.com/alangrainger/immich-public-proxy/blob/main/docs/securing-immich-with-mtls.md
    # TODO: Consider immich-public-proxy for generating "share" links
    # https://github.com/alangrainger/immich-public-proxy
    services.immich = {
      enable = true;
      openFirewall = true;
      port = 2283; # default
      #secretsFile = config.sops.secrets.immich_env.path;

      # TODO: Build this directory with permissions for the immich user.
      mediaLocation = lib.toString immichMediaDir;
      environment = {
        #IMMICH_CONFIG_FILE = config.sops.templates."immich.json".path;
      };
    };

    # services.kanidm.provision.systems.oauth2.immich = {
    #   displayName = "immich";
    #   originUrl = "https://${svcDomain}/oauth2/oidc/callback";
    #   originLanding = "https://${svcDomain}/";
    #   basicSecretFile = config.sops.secrets."immich/oauth2_client_secret".path;
    #   scopeMaps."immich.users" = [
    #     "openid"
    #     "email"
    #     "profile"
    #   ];
    #   preferShortUsername = true;
    # };
  };
}
