{ pkgs, lib, inputs, ... }:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ../../users/jml
  ];
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # NOTE: Matches zw.base (modules/roles/base.nix); m5mbp bypasses mkSystem's
  # sharedModules seam, so it doesn't get the role and must set this itself.
  nix.settings.accept-flake-config = true;
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
