{ config, pkgs, ... }:
{
  sops.defaultSopsFile = ./secrets/common.yaml;
  networking.hostName = "lithium";
  networking.domain = config.vars.domain;
  environment.systemPackages = with pkgs; [
    zfs
  ];
  services.openssh.enable = true;
  programs.mosh.enable = true; 
  system.stateVersion = "25.05";
}

