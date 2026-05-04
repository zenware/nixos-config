{
  config,
  lib,
  pkgs,
  ...
}:
let
  retroarchWithCores = (
    pkgs.retroarch.withCores (
      cores: with cores; [
        # Multi-Emulators
        mame # Atari / Nintendo / Sega / etc.

        # Sega
        genesis-plus-gx # Sega Genesis

        # Nintendo
        mesen # NES
        bsnes # Super Nintendo
        mupen64plus # Nintendo 64 - Maybe simple64 some day.
        dolphin # GameCube
        mgba # GameBoy / Color / Advance
        #melonds  # Nintendo DS
        #citra  # Nintendo 3DS

        # Sony
        swanstation # duckstation  # PlayStation
        beetle-psx-hw
        pcsx2 # PlayStation 2 -- Is actually "LRPS2"
        #rpcs3  # PlayStation 3
        ppsspp # PlayStation Portable

        # Commodore
        vice-x64 # C64
      ]
    )
  );
in
{
  options.zw.game-emulation = {
    enable = lib.mkEnableOption "game emulation";
  };

  config = lib.mkIf config.zw.game-emulation.enable {
    environment.systemPackages = [
      retroarchWithCores
      #pkgs.retroarch-full
      #pkgs.emulationstation-de
      pkgs.gnome-bluetooth
    ];

    # TODO: Move some of this into modules/nixos/bluetooth.nix OR enable it only
    # when the bluetooth options are already enabled. It's possible I want to play
    # game emulators on a system without bluetooth enabled.
    hardware.xone.enable = true; # Xbox Controller Driver
    hardware.xpadneo.enable = true; # Xbox Controller Driver
    hardware.enableAllFirmware = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };
  };
}
