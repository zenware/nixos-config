{ pkgs, lib, ... }: {
  environment.systemPackages = [ pkgs.sbctl ];
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote.enable = true;
  boot.lanzaboote.pkiBundle = "/var/lib/sbctl";
}
