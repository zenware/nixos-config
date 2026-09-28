{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.zw.game-servers.palworld;
  stateDir = "/var/lib/palworld";
  settingsDir = "${stateDir}/palworld/Pal/Saved/Config/LinuxServer";
  palworldHash = "sha256-zx2mj6IYqkFjoKtrKWRAy7/J2G8WhdZX0xKY6MuabLY=";
  palworldServer = pkgs.mkSteamServer rec {
    name = "palworld";
    src = pkgs.fetchSteam {
      inherit name;
      appId = "2394010";
      hash = "${palworldHash}";
    };
    startCmd = "PalServer.sh";
    hash = "${palworldHash}";
  };
in
{
  # TODO: Organize the game-servers options better.
  options.zw.game-servers = {
    enable = lib.mkEnableOption "Game servers";
  };
  options.zw.game-servers.palworld = {
    enable = lib.mkEnableOption "Palworld server";
    configFile = lib.mkOption {
      type = lib.types.path;
      default = pkgs.writeText "palworld-settings.ini" ''
        [/Script/Pal.PalGameWorldSettings]
        OptionSettings=(ServerName="lithium Palworld",ServerDescription="Palworld server",ServerPassword="FAKE-PALWORLD-SERVER-PASSWORD",AdminPassword="FAKE-PALWORLD-ADMIN-PASSWORD",PublicPort=${toString config.zw.servicePorts.udp.palworldGame},RCONEnabled=False)
      '';
      description = "PalWorldSettings.ini installed before the Palworld server starts.";
    };
  };

  # Only build this if both game-servers generally AND palworld in-specific are enabled.
  config = lib.mkIf (config.zw.game-servers.enable && cfg.enable) {
    users.users.flux = {
      isSystemUser = true;
      group = "flux";
      home = stateDir;
    };
    users.groups.flux = { };

    networking.firewall.allowedUDPPorts = with config.zw.servicePorts.udp; [
      palworldGame
      palworldQuery
    ];

    systemd.services.palworld = {
      description = "Palworld dedicated server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      preStart = lib.mkBefore ''
        install -d -m 0750 -o flux -g flux ${settingsDir}
        install -m 0640 -o flux -g flux ${cfg.configFile} ${settingsDir}/PalWorldSettings.ini
      '';
      restartTriggers = [ cfg.configFile ];
      serviceConfig = {
        ExecStart = lib.getExe palworldServer;
        User = "flux";
        Group = "flux";
        StateDirectory = "palworld";
        StateDirectoryMode = "0750";
        WorkingDirectory = stateDir;
        Nice = -5;
        Restart = "always";
      };
    };
  };
}
