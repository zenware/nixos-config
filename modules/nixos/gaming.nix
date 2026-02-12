{
  config,
  lib,
  pkgs,
  ...
}:
{
  #imports = [];
  options = {
    zw.gaming.enable = lib.mkEnableOption "Enable Gaming";
  };

  # https://wiki.nixos.org/wiki/Category:Gaming
  config = lib.mkIf config.zw.gaming.enable {
    environment.systemPackages = with pkgs; [
      mangohud
      protonup-qt
      lutris # TODO: Having an issue after flake update
      bottles
      heroic
    ];
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      protontricks.enable = true;
      gamescopeSession.enable = true;
    };

    programs.gamemode.enable = true;
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };
  };
}
