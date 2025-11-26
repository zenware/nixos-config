{ config, lib, pkgs, ... }:
let
  retroarchWithCores = (
    pkgs.retroarch.withCores (
      cores: with cores; [
        # Multi-Emulators
        mame  # Atari / Nintendo / Sega / etc.

        # Sega
        genesis-plus-gx  # Sega Genesis

        # Nintendo
        mesen  # NES
        bsnes  # Super Nintendo
        mupen64plus # Nintendo 64 - Maybe simple64 some day.
        dolphin  # GameCube
        mgba  # GameBoy / Color / Advance
        #melonds  # Nintendo DS
        #citra  # Nintendo 3DS


        # Sony
        swanstation  #duckstation  # PlayStation
        beetle-psx-hw
        pcsx2  # PlayStation 2 -- Is actually "LRPS2"
        #rpcs3  # PlayStation 3
        ppsspp  # PlayStation Portable

        # Commodore
        vice-x64  # C64
      ]
    )
  );
in
{
  environment.systemPackages = [
    retroarchWithCores
    #pkgs.retroarch-full
    #pkgs.emulationstation-de
    pkgs.gnome-bluetooth
  ];

  hardware.xone.enable = true;  # Xbox Controller Driver
  hardware.xpadneo.enable = true;  # Xbox Controller Driver
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
}
