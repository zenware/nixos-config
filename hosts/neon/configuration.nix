{ ... }:
{
  networking.hostName = "neon";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  system.stateVersion = "23.05";
}
