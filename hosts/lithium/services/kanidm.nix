{ inputs, config, pkgs, lib, ... }:
let
  svcDomain = "id.${config.networking.domain}";
  kanidmCertDir = "/var/lib/kanidm/certs";
  caddyCertStore = "${config.services.caddy.dataDir}/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${svcDomain}";
  #kcertloc = "${caddyCertsStore}/${svcDomain}/";
  certRenewalScript = pkgs.writeShellScript "copy-kanidm-cert-hook" ''
    set -Eeuo pipefail
    mkdir -p ${kanidmCertDir}
    cp ${caddyCertStore}/${svcDomain}.crt ${kanidmCertDir}/cert.pem
    cp ${caddyCertStore}/${svcDomain}.key ${kanidmCertDir}/key.pem

    chown kanidm:kanidm ${kanidmCertDir}/*.pem

    ${pkgs.systemd}/bin/systemctl restart kanidm.service
  '';
  kanidmCertCopier = "kanidm-cert-copier";
in
{
  # NOTE: Domains are serious when they are the root of identity/authnz.
  # Recommendation from Kanidm docs for "Maximum" security is to maintain
  # Both `example.com` and `id.example-auth.com`, the latter for idm infra exclusively.
  # I consider that to be untenable and in some ways even more risky.
  # The next recommendation is to follow a pattern like so
  # id.example.com
  # australia.id.example.com
  # id-test.example.com
  # australia.id-test.example.com
  
  # Example of yoinking certs from caddy:
  # https://github.com/marcusramberg/nix-config/blob/e558914dd3705150511c5ef76278fc50bb4604f3/nixos/kanidm.nix#L3

  # TODO: If possible, consider specifying the cert location here instead of the following kludge.
  services.caddy.virtualHosts."${svcDomain}".extraConfig = ''
    reverse_proxy :8443 {
      header_up Host {host}
      header_up X-Real-IP {http.request.header.CF-Connecting-IP}
      transport http {
        tls_server_name ${svcDomain}
      }
    }
  '';

  # NOTE: Cleanup old rules
  # systemd.tmpfiles.rules = lib.filter(rule: ! (lib.strings.hasPrefix "C ${kanidmCertDir}" rule)) config.systemd.tmpfiles.rules;
  systemd.tmpfiles.rules = [
    "d ${kanidmCertDir} 0750 kanidm kanidm -"
  ];
  # NOTE: Include automation for copying cert files on renewal.
  # systemd.services.caddy.serviceConfig = {
  #   ExecStartPost = [
  #       "${certRenewalScript}/bin/copy-kanidm-cert-hook"
  #   ];
  #   ExecReload = [
  #       "${pkgs.caddy}/bin/caddy reload --config ${config.services.caddy.configFile}"
  #       "${certRenewalScript}/bin/copy-kanidm-cert-hook"
  #   ];
  # };
  systemd.services.${kanidmCertCopier} = {
    description = "Copy Caddy certificates for Kanidm";
    requires = [ "caddy.service" ];
    after = [ "caddy.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "${certRenewalScript}";
    };
  };
  # systemd.services.caddy.wantedBy = [ "multi-user.target" ];
  # systemd.services.caddy.wants = [ kanidmCertCopier ];
  systemd.services.caddy.reloadTriggers = [ kanidmCertCopier ];
  systemd.timers.kanidm-cert-copier-daily = {
    wantedBy =  [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnCalendar = "daily";
      Unit = kanidmCertCopier;
    };
  };

  # systemd.services.kanidm = {
  #   after = [ kanidmCertCopier ];
  #   requires = [ kanidmCertCopier ];
  # };
  users.users.kanidm.extraGroups = [
    "caddy"
  ];

  services.kanidm = {
    # NOTE: This upgrade probably bones everything, but it's all boned anyway.
    package = pkgs.kanidmWithSecretProvisioning_1_8;
    server.enable = true;
    server.settings = {
      # NOTE: Required to start the server: https://kanidm.github.io/kanidm/stable/server_configuration.html
      # domain, origin, tls_chain, tls_key
      domain = svcDomain;
      origin = "https://${svcDomain}";
      tls_chain = "${kanidmCertDir}/cert.pem";
      tls_key = "${kanidmCertDir}/key.pem";
      # tls_chain = "${caddyCertStore}/${svcDomain}.crt";
      # tls_key = "${caddyCertStore}/${svcDomain}.key";

      # NOTE: Optional Settings
      # TODO: Configure the rest of the binding properly, should be 363 and maybe 8443
      ldapbindaddress = "127.0.0.1:3636";  # For Jellyfin LDAP integration.

      #trust_x_forwarded_for = true;
    };

    enableClient = true;
    clientSettings.uri = config.services.kanidm.serverSettings.origin;

    # NOTE: POSIX accounts bound to LDAP assume 'anonymous' permissions.
    # https://kanidm.github.io/kanidm/stable/integrations/pam_and_nsswitch.html
    enablePam = true;
    unixSettings = {
      kanidm.pam_allowed_login_groups = [
        "unix.admins"
      ];
      home_attr = "uuid";
      home_alias = "name";
    };

    # TODO: Migrate the secrets from here to `nixos-secrets`
    # NOTE: There are manual steps required as root to allow a user to set
    # their own credentials, or to confiugre an account as posix. As-is this
    # module doesn't support provisioning a complete user /w credentials.
    # Adding an account to `idm_high_privilege` prevents an account from being
    # tampered with by any other admin accounts.
    # https://kanidm.github.io/kanidm/stable/accounts/authentication_and_credentials.html#onboarding-a-new-person--resetting-credentials
    provision = {
      enable = true;
      autoRemove = true;
      acceptInvalidCerts = true;

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
            "immich.users"
            "miniflux.users"
          ];
        };
      };
      groups = {
        "unix.admins" = {};
        "git.users" = {};
        "git.admins" = {};
        "tv.users" = {};
        "tv.admins" = {};
        "immich.users" = {};
        "miniflux.users" = {};
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
