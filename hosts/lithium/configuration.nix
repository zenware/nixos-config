{
  config,
  pkgs,
  lib,
  ...
}:
{
  #sops.defaultSopsFile = ./secrets/common.yaml;
  networking.hostName = "lithium";
  # NOTE: zw.homelab.domain (see modules/flake/homelab.nix) is set to the
  # real domain in `nixos-secrets`; here it stays on the home.arpa default.
  environment.systemPackages = with pkgs; [
    zfs
  ];
  services.openssh.enable = true;
  programs.mosh.enable = true;
  system.stateVersion = "25.05";
}
