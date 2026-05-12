{ pkgs, lib, inputs, ... }:
{
  imports = [
    ../../users/jml
  ];
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Bitwarden, Signal, Raycast? Terminal
  # Zed, Ripgrep
  environment.systemPackages = [
    pkgs.home-manager
    pkgs.signal-desktop
    pkgs.obsidian
    pkgs.bitwarden-desktop
    pkgs.zed-editor
    pkgs.ripgrep
  ];

  programs = {
    zsh.enable = true;
  };

  # Auto upgrade nix pkg and daemon service
  # services.nix-daemon.enable = true;
  nix.enable = true;

  system.primaryUser = "jml";
  system.defaults = {
    dock = {};
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
    };
    NSGlobalDomain = {};
  };
 
  # Necessary pieces, do not edit below this line.
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
}
