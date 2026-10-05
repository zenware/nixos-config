{
  flake.modules.nixos.guest =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.zw.guest;
      username = "guest";
      home = "/home/${username}";
      keepReadme = pkgs.writeText "guest-keep-readme" ''
        Files in this directory survive the nightly guest account reset.
        Files older than ${toString cfg.keepDays} days are removed automatically.
      '';
    in
    {
      options.zw.guest = {
        enable = lib.mkEnableOption "the limited guest desktop account";

        resetSchedule = lib.mkOption {
          type = lib.types.str;
          default = "*-*-* 00:00:00";
          description = "systemd OnCalendar schedule for resetting the guest account.";
        };

        keepDays = lib.mkOption {
          type = lib.types.ints.positive;
          default = 7;
          description = "Maximum age of files retained in the guest Keep directory.";
        };

        packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = with pkgs; [
            firefox
            brave
            libreoffice-qt
            hunspell
            hunspellDicts.en_US
            hunspellDicts.es_ANY
            gimp3
            zoom-us
            vlc
            unrar
            p7zip
            kdePackages.kcalc
            kdePackages.kcharselect
            kdePackages.skanlite
          ];
          description = "Applications installed in the guest user's profile.";
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = config.zw.desktop.enable && builtins.elem "plasma" config.zw.desktop.sessions;
            message = "zw.guest.enable requires the Plasma desktop session";
          }
        ];

        users.users.${username} = {
          isNormalUser = true;
          description = "Guest";
          inherit home;
          createHome = true;
          hashedPassword = "";
          packages = cfg.packages;
        };

        security.pam.services.sddm.allowNullPassword = true;

        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (subject.user == "${username}" &&
                (action.id == "org.freedesktop.accounts.change-own-password" ||
                 action.id == "org.freedesktop.accounts.change-own-user-data" ||
                 action.id == "org.freedesktop.accounts.set-login-option" ||
                 action.id == "org.freedesktop.accounts.user-administration")) {
              return polkit.Result.NO;
            }
          });
        '';

        systemd.tmpfiles.rules = [
          "d ${home}/Keep 0700 ${username} users -"
          "e ${home}/Keep 0700 ${username} users ${toString cfg.keepDays}d"
          "C+ ${home}/Keep/README.txt 0600 ${username} users - ${keepReadme}"
        ];

        systemd.services.guest-reset = {
          description = "Reset the guest account";
          serviceConfig.Type = "oneshot";
          path = with pkgs; [
            coreutils
            findutils
            systemd
          ];
          script = ''
            sessions="$(loginctl show-user ${username} --property=Sessions --value 2>/dev/null || true)"
            if [ -n "$sessions" ]; then
              echo "Guest has an active session; skipping reset"
              exit 0
            fi

            install -d -m 0700 -o ${username} -g users ${home}
            find ${home} -mindepth 1 -maxdepth 1 ! -name Keep -exec rm -rf -- {} +
            if [ -L ${home}/Keep ] || [ ! -d ${home}/Keep ]; then
              rm -rf -- ${home}/Keep
              install -d -m 0700 -o ${username} -g users ${home}/Keep
            else
              chown ${username}:users ${home}/Keep
              chmod 0700 ${home}/Keep
            fi
            install -m 0600 -o ${username} -g users ${keepReadme} ${home}/Keep/README.txt
          '';
        };

        systemd.timers.guest-reset = {
          description = "Nightly guest account reset";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = cfg.resetSchedule;
            Persistent = true;
            Unit = "guest-reset.service";
          };
        };
      };
    };
}
