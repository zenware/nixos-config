{
  config,
  lib,
  pkgs,
  ...
}:
{
  powerManagement.enable = false;
  networking.hostName = "titanium";
  networking.networkmanager.enable = true;
  environment.systemPackages = with pkgs; [
    sbctl # Secure-Boot
    helix
    nil # nice for editing '.nix'
    (discord.override { withVencord = true; })
    signal-desktop
    obs-studio
    halloy # IRC
    gimp3
    # nyxt # browser - Was accidentally defaulting?
  ];
  # Hardware Specific programs...
  #programs.ryzen-monitor-ng.enable = true;
  #programs.rog-control-center.enable = true;
  services.openssh.enable = true;
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  system.stateVersion = "25.11";
}
