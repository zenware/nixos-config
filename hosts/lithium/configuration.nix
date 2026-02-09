{ config, pkgs, lib, ... }:
{
  #sops.defaultSopsFile = ./secrets/common.yaml;
  networking.hostName = "lithium";
  # NOTE: networking.domain should likely be overridden in `nixos-secrets` for this host.
  # networking.domain = lib.mkForce config.vars.domain;
  environment.systemPackages = with pkgs; [
    zfs
  ];
  services.openssh.enable = true;
  programs.mosh.enable = true; 
  system.stateVersion = "25.05";
}
