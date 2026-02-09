{ config, pkgs, ... }:
let
  homelabDomain = config.networking.domain;
  svcDomain = "feeds.${homelabDomain}";
  svcPort = "8081";  # Prevent a Conflict
in
{
  services.caddy.virtualHosts."${svcDomain}".extraConfig = ''
    reverse_proxy :${svcPort}
  '';
  # NOTE: Ensure the user exists ahead of trying to give secret permissions to that user.
  users.users.miniflux = {
    isSystemUser = true;
    group = "miniflux";
    createHome = false;
  };
  users.groups.miniflux = {};
  #services.kanidm.provision = {
    #groups = {};
    #systems.oauth2.miniflux = {
      #displayName = "Miniflux Feed Reader";
      #originUrl = "https://${fqdn}/callback";
      #public = true; # enforces PKCE
      #preferShortUsername = true;
      #scopeMaps.pages_users = ["openid" "email" "profile"];
      #claimMaps."${permissionsMap}".valuesByGroup.pages_admin = ["admin"];
    #};
  #};
  # NOTE: Currently requires some web-interface configuration
  services.miniflux = {
    enable = true;
    #adminCredentialsFile = config.sops.secrets.miniflux_env.path;
    config = {
      BASE_URL = "https://${svcDomain}";
      CREATE_ADMIN = 0;  # NOTE: Override this to 1 in secrets
      #DISABLE_LOCAL_AUTH = 1;
      OAUTH2_PROVIDER = "oidc";
      OAUTH2_CLIENT_ID = "miniflux";
      #OAUTH2_CLIENT_SECRET_FILE = config.sops.secrets."miniflux/oauth2_client_secret".path;
      OAUTH2_REDIRECT_URL = "https://${svcDomain}/oauth2/oidc/callback";
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://id.${homelabDomain}/oauth2/openid/miniflux";
      #OAUTH2_USER_CREATION = 1;
      CLEANUP_FREQUENCY = 48;
      LISTEN_ADDR = "localhost:${svcPort}";
    };
  };

  
  services.kanidm.provision.systems.oauth2.miniflux = {
    displayName = "miniflux";
    originUrl = "https://${svcDomain}/oauth2/oidc/callback";
    originLanding = "https://${svcDomain}/";
    #basicSecretFile = config.sops.secrets."miniflux/oauth2_client_secret".path;
    scopeMaps."miniflux.users" = [
      "openid"
      "email"
      "profile"
      "groups"
    ];
    # WARNING: PKCE is currently not supported by gitea/forgejo,
    # see https://github.com/go-gitea/gitea/issues/21376
    allowInsecureClientDisablePkce = true;
    preferShortUsername = true;
  };
}
