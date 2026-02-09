{ config, pkgs, lib, ... }:
let
  homelabDomain = config.networking.domain;
  svcDomain = "git.${homelabDomain}";
  theme = pkgs.fetchzip {
    url = "https://github.com/catppuccin/gitea/releases/download/v1.0.2/catppuccin-gitea.tar.gz";
    hash = "sha256-rZHLORwLUfIFcB6K9yhrzr+UwdPNQVSadsw6rg8Q7gs=";
    stripRoot = false;  
  };
  svcHttpPort = config.services.forgejo.settings.server.HTTP_PORT;
  assetsDir = "${config.services.forgejo.stateDir}/custom/public/assets";
in
{
  # NOTE: Periodically come update the catpuccin theme.
  # `-auto` will automatically switch between latte and mocha modes.
  services.forgejo.settings.ui = {
    DEFAULT_THEME = "catpuccin-teal-auto";
    THEMES = builtins.concatStringsSep "," (
      [ "auto" ]
      ++ (map (name: lib.removePrefix "theme-" (lib.removeSuffix ".css" name)) (
        builtins.attrNames (builtins.readDir theme)
      ))
    );
  };

  # TODO: Setup a PostgreSQL Server.
  # Inspiration here: https://github.com/nyawox/arcanum/blob/4629dfba1bc6d4dd2f4cf45724df81289230b61a/nixos/servers/forgejo.nix#L64
  #sops-secrets.postgres-forgejo = {
    #sopsFile = ../secrets/forgejo.yaml;
  #};

  services.caddy.virtualHosts."${svcDomain}".extraConfig = ''
    reverse_proxy :${toString svcHttpPort}
  '';

  services.forgejo = {
    enable = true;
    # database.type = "postgres";
    settings = {
      default.APP_NAME = "GitGarage";
      server = {
        DOMAIN = svcDomain;
        ROOT_URL = "https://${svcDomain}";
        HTTP_PORT = 3000;
      };
      # NOTE: Actions support is based on: https://github.com/nektos/act
      #actions = {
        #ENABLED = true;
        #DEFAULT_ACTIONS_URL = "github";
      #};
      actions.ENABLED = false;
      # NOTE: Registration is handled with kanidm.
      # Registration button link is at /user/sign_up
      service = {
        REGISTER_EMAIL_CONFIRM = false;
        DISABLE_REGISTRATION = false;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
        SHOW_REGISTRATION_BUTTON = false;
        REQUIRE_SIGNIN_VIEW = false;
        # TODO: Consider setting up emails.
        ENABLE_NOTIFY_MAIL = false;
      };
      openid = {
        ENABLE_OPENID_SIGNIN = true;
        ENABLE_OPENID_SIGNUP = true;
        WHITELISTED_URIS = "id.${homelabDomain}";
      };
      # TODO: Literally review all server settings, and link the forgejo documentation.
      # Also perhaps include every setting here explicitly.
      oauth2_client = {
        REGISTER_EMAIL_CONFIRM = false;
        ENABLE_AUTO_REGISTRATION = true;
        ACCOUNT_LINKING = "login";
        USERNAME = "nickname";
        UPDATE_AVATAR = true;
        OPENID_CONNECT_SCOPES = "openid email profile";
      };
      repository = {
        DEFAULT_PRIVATE = "private";
        DEFAULT_BRANCH = "main";
        ENABLE_PUSH_CREATE_USER = true;
        ENABLE_PUSH_CREATE_ORG = true;
      };
      mailer.ENABLED = false;
    };
  };

  # TODO: Finish Configuring the kandim oauth for forgejo....
  services.kanidm.provision.systems.oauth2.forgejo = {
    displayName = "forgejo";
    # TODO: Get this from Forgejo
    # originUrl = "https://git.${homelabDomain}/user/oauth2/${homelabDomain}/callback";
    originUrl = "${config.services.forgejo.settings.server.ROOT_URL}/user/oauth2/kanidm/callback";
    originLanding = "https://git.${homelabDomain}/";
    #basicSecretFile = "TODO!SETME";
    scopeMaps."git.users" = [
      "openid"
      "email"
      "profile"
      "groups"
    ];
    # WARNING: PKCE is currently not supported by gitea/forgejo,
    # see https://github.com/go-gitea/gitea/issues/21376
    allowInsecureClientDisablePkce = true;
    preferShortUsername = true;
    claimMaps.groups = {
      joinType = "array";
      valuesByGroup."git.admins" = [ "admin" ];
    };
  };

  systemd.services.forgejo = {
    preStart =
      lib.mkAfter # bash
      ''
        echo "Installing Catppuccin Assets"
        rm -rf ${assetsDir}
        mkdir -p ${assetsDir}
        ln -sf ${theme} ${assetsDir}/css
      '';
  };


  #sops.secrets.forgejo-runner-token = {};
  #services.gitea-actions-runner = {
    #package = pkgs.forgejo-runner;
    #instances.default = {
      #enable = true;
      #name = "monolith";
      #url = "https://${serviceDomain}";
      #tokenFile = config.sops.secrets.forgejo-runner-token.path;
      # NOTE: I don't want huge images if it can be avoided.
      # https://nektosact.com/usage/runners.html
      #labels = [
        #"ubuntu-latest:docker://node:16-bullseye-slim"
        #"ubuntu-22.04:docker://node:16-bullseye-slim"
      #];
    #};
  #};

  # TODO: Consider automatically creating admin account and password...
  # https://wiki.nixos.org/wiki/Forgejo#Ensure_users
  # Might be necessary to generate a token for kanidm
  # Maybe check sops.defaultSopsFile
}
