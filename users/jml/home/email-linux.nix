{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.isLinux (import ./email.nix { inherit pkgs lib; })
