{ pkgs, ... }:
{
  # Default to systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  
  boot = {
    # Visuals
    plymouth = {
      enable = true;
      theme = "owl";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "owl" ];
        })
      ];
    };

    # "Silent" / Fast Boot
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
    # Hold a key to show bootloader choice.
    loader.timeout = 0;
  };
}
