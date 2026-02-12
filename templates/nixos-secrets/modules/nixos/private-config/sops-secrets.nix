{ config, lib, ... }:
{
  config = {
    sops = {
      defaultSopsFile = ../../../lithium/secrets.yaml;
    };

    sops.secrets = {
      "kanidm/admin-password" = { group = "kanidm"; mode = "440"; };
      "kanidm/idm-admin-password" = { group = "kanidm"; mode = "440"; };
    };
    services.kanidm.provision = {
      adminPasswordFile = config.sops.secrets."kanidm/admin-password".path;
      idmAdminPasswordFile = config.sops.secrets."kanidm/idm-admin-password".path;
    };

    sops.secrets.caddy_env = {
      sopsFile = ../../../lithium/cloudflare.env;
      format = "dotenv";
      mode = "0440";
      owner = config.services.caddy.user;
      group = config.services.caddy.group;
      restartUnits = [ "caddy.service" ];
    };
    services.caddy.environmentFile = config.sops.secrets.caddy_env.path;

    sops.secrets."immich/oauth2_client_secret" = { };
    sops.templates."immich.json" = {
      mode = "0440";
      owner = config.services.immich.user;
      group = config.services.immich.group;
      #content = builtins.toJSON {};  # TODO: add more sophisticated JSON settings.
    };
    services.immich.environment.IMMICH_CONFIG_FILE = config.sops.templates."immich.json".path;

    sops.secrets."forgejo/admin-password".owner = "forgejo";
    services.kanidm.provision.systems.oauth2.forgejo.basicSecretFile = config.sops.secrets."forgejo/admin-password".path;

    sops.secrets.miniflux_env = {
      sopsFile = ../../../lithium/miniflux_admin_credentials.env;
      format = "dotenv";
      mode = "0440";
      owner = "miniflux";
      group = "miniflux";
      restartUnits = [ "miniflux.service" ];
    };
    sops.secrets."miniflux/oauth2_client_secret" = {
      owner = "miniflux";
      group = "kanidm";
      mode = "0440";
      restartUnits = [ "miniflux.service" "kanidm.service" ];
    };
    services.miniflux.adminCredentialsFile = config.sops.secrets.miniflux_env.path;
    services.miniflux.config.CREATE_ADMIN = lib.mkForce 1;
    services.miniflux.config.OAUTH2_CLIENT_SECRET_FILE = config.sops.secrets."miniflux/oauth2_client_secret".path;
    services.kanidm.provision.systems.oauth2.miniflux.basicSecretFile = config.sops.secrets."miniflux/oauth2_client_secret".path;
  };
}
