{ inputs, pkgs, ... }:
{
  # NOTE: Only host-specific concerns (hardware, boot, quirks) are imported
  # here. Shared roles (base, desktop, bluetooth, laptop, ...) are
  # auto-imported on every host from modules/roles/ and toggled via the
  # zw.* options below.
  imports = [
    ./boot.nix
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
