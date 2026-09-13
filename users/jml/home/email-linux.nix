{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux (import ./email.nix { inherit pkgs lib; })
