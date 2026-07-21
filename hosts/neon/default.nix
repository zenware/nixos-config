{ inputs, pkgs, ... }:
{
  imports = [
    ./boot.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/laptop.nix
    # https://github.com/NixOS/nixos-hardware/blob/master/README.md#using-nix-flakes-support
    inputs.nixos-hardware.nixosModules.gpd-pocket-3
    # override from nixos-hardware
    (
      { lib, ... }:
      {
        services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];
      }
    )
    ./hardware-configuration.nix
    ./configuration.nix
  ];

  #nixpkgs.config.allowUnfree = true;
  #nixpkgs.config.android_sdk.accept_license = true;
  environment.systemPackages = with pkgs; [
    godot
    # android-studio
    # android-tools
    # androidenv.androidPkgs.androidsdk
    # androidenv.androidPkgs.emulator
    # androidenv.androidPkgs.ndk-bundle
    # jdk # Java
  ];

  zw.desktop.enable = true;
  zw.laptop.enable = true;
  zw.bluetooth.enable = true;
}
