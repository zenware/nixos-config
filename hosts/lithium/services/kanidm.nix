{ config, pkgs, lib, ... }:
let
  svcDomain = "id.${config.networking.domain}";
  caddyCertsRoot = "${config.services.caddy.dataDir}/.local/share/caddy/certificates";
  caddyCertsDir = "${caddyCertsRoot}/acme-v02.api.letsencrypt.org-directory";
  certsDir = "/var/lib/kanidm/certs";
in
{
  # Example of yoinking certs from caddy:
  # https://github.com/marcusramberg/nix-config/blob/e558914dd3705150511c5ef76278fc50bb4604f3/nixos/kanidm.nix#L3

  # TODO: If possible, consider specifying the cert location here instead of the following kludge.
  services.caddy.virtualHosts."${svcDomain}".extraConfig = ''
    reverse_proxy :8443 {
      transport http {
        tls_server_name ${svcDomain}
      }
    }
  '';

  # NOTE: Attempted kludge due to caddy generating (and therefore owning the certs)
  systemd.tmpfiles.rules = [
    "d ${certsDir} 0750 kanidm caddy -"
    "C ${certsDir}/cert.pem - kanidm - - ${caddyCertsDir}/${svcDomain}/${svcDomain}.crt"
    "C ${certsDir}/key.key  - kanidm - - ${caddyCertsDir}/${svcDomain}/${svcDomain}.key"
  ];
  systemd.services.kanidm = {
    after = [ "systemd-tmpfiles-setup.service" ];
    requires = [ "caddy.service" "systemd-tmpfiles-setup.service" ];
  };
  users.users.kanidm.extraGroups = [
    "caddy"
  ];

  sops.secrets = {
    "kanidm/admin-password" = {
      group = "kanidm";
      mode = "440";
    };
    "kanidm/idm-admin-password" = {
      group = "kanidm";
      mode = "440";
    };
  };

  services.kanidm = {
    package = pkgs.kanidmWithSecretProvisioning_1_7;
    enableServer = true;
    serverSettings = {
      # NOTE: Required to start the server: https://kanidm.github.io/kanidm/stable/server_configuration.html
      # domain, origin, tls_chain, tls_key
      domain = svcDomain;
      origin = "https://${svcDomain}";
      tls_chain = "${certsDir}/cert.pem";
      tls_key = "${certsDir}/key.key";

      # NOTE: Optional Settings
      ldapbindaddress = "127.0.0.1:3636";  # For Jellyfin LDAP integration.

      # trust_x_forwarded_for = true;
    };

    enableClient = true;
    clientSettings.uri = config.services.kanidm.serverSettings.origin;

    # NOTE: POSIX accounts bound to LDAP assume 'anonymous' permissions.
    # https://kanidm.github.io/kanidm/stable/integrations/pam_and_nsswitch.html
    enablePam = true;
    unixSettings = {
      pam_allowed_login_groups = [
        "unix.admins"
      ];
      home_attr = "uuid";
      home_alias = "name";
    };

    # NOTE: There are manual steps required as root to allow a user to set
    # their own credentials, or to confiugre an account as posix. As-is this
    # module doesn't support provisioning a complete user /w credentials.
    # Adding an account to `idm_high_privilege` prevents an account from being
    # tampered with by any other admin accounts.
    # https://kanidm.github.io/kanidm/stable/accounts/authentication_and_credentials.html#onboarding-a-new-person--resetting-credentials
    provision = {
      enable = true;
      autoRemove = false;
      adminPasswordFile = config.sops.secrets."kanidm/admin-password".path;
      idmAdminPasswordFile = config.sops.secrets."kanidm/idm-admin-password".path;

      # NOTE: Basically all this can do is pair up a uuid with a collection of
      # groups, and you still need to manually issue a reset token so that the
      # user can create a Passekey and/or Password /w MFA.
      persons = {
        # https://kanidm.github.io/kanidm/stable/accounts/authentication_and_credentials.html#resetting-person-account-credentials
        zenware = {
          displayName = "zenware";
          groups = [
            "unix.admins"
            "git.users"
            "git.admins"
            "tv.users"
          ];
        };
      };
      groups = {
        "unix.admins" = {};
        "git.users" = {};
        "git.admins" = {};
        "tv.users" = {};
        "tv.admins" = {};
      };
    };
  };

  # NOTE: Allow Kanidm auth over SSH
  services.openssh.settings = {
    UsePAM = true;
    PubkeyAuthentication = true;
    PasswordAuthentication = true;
    AuthorizedKeysCommand = "${
      lib.getExe' config.services.kanidm.package
      "kanidm_ssh_authorizedkeys"
    } %u";
    AuthorizedKeysCommandUser = "nobody";
  };

}
