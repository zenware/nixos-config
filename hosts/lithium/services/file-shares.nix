{ ... }:
{
  # NOTE: We do need to guarantee this group exists.
  # and manually provision users with `sudo smbpasswd -a $username`
  users.groups.samba = {};
  services.samba = {
    enable = true;
    openFirewall = true;

    nmbd.enable = false;  # NOTE: Disable NetBIOS responses.
    # usershares.enable = true;  # NOTE: Members of group "samba" can create usershares.

    # NOTE: Refer to https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
    # to configure this service.
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "hosts allow" = "192.168.50.";
        "hosts deny" = "ALL";
        "guest account" = "nobody";
        "map to guest" = "bad user";

        "log file" = "/var/log/samba/%m.log";
        "max log size" = 1000;

        "create mask" = "0660";
        "directory mask" = "2770";
      };

      # NOTE: usershares enables users to create their own shares. This creates
      # a share per-user.
      homes = {
        browseable = "no";
        writable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "%S"; 
        path = "/tank/shares/personal/%S";
      };

      staging = {
        comment = "Temp Upload Area";
        path = "/tank/shares/staging";
        browseable = "yes";
        writable = "yes";
        "guest ok" = "yes";
        "force user" = "nobody";
        "force group" = "nogroup";
        "create mask" = "0666";
        "directory mask" = "0777";
      };

      backups = {
        comment = "Device Backups";
        path = "/tank/shares/backups";
        browseable = "no";
        writable = "yes";
        "valid users" = "@samba";
        "guest ok" = "no";
      };

      ## TODO: Time Machine Configuration
      # http://wiki.nixos.org/wiki/Samba#Apple_Time_Machine
    };
  };

  # NOTE: This is used to advertise shares to Windows hosts.
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
  #services.avahi = {
    #enable = true;
    #openFirewall = true;
    #publish.enable = true;
    #publish.userServices = true;
  #};
}
