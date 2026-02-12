{
  config,
  pkgs,
  lib,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  # TODO: Consider adding a randomized delay.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # https://datatracker.ietf.org/doc/html/rfc8375
  networking.domain = lib.mkDefault "home.arpa";

  # TODO: Consider enabling automatic-timezoned on laptops that move between TZs
  time.timeZone = lib.mkDefault "America/Chicago";
  services.automatic-timezoned.enable = lib.mkDefault false;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  console.font = null; # Kernel will automatically choose a font.
  console.keyMap = "us";
  # 4-bit ANSI -> Catpuccin Mocha Colors: https://catppuccin.com/palette/
  console.colors = [
    "11111b" # black               -> crust
    "f38ba8" # red                 -> red
    "a6e3a1" # green               -> green
    "fab387" # yellow              -> peach
    "89b4fa" # blue                -> blue
    "cba6f7" # magenta             -> mauve
    "74c7ec" # cyan                -> sapphire
    "6c7086" # white               -> overlay 0
    "313244" # bright black (gray) -> surface 0
    "eba0ac" # bright red          -> maroon
    "94e2d5" # bright green        -> teal
    "f9e2af" # bright yellow       -> yellow
    "b4befe" # bright blue         -> lavender
    "f5c2e7" # bright magenta      -> pink
    "89dceb" # bright cyan         -> sky
    "cdd6f4" # bright white        -> text
  ];

  # TODO: Consider zsh for default shell.
  #users.defaultUserShell = pkgs.zsh;

  networking.firewall.enable = true;

  # Installed on every NixOS Host.
  environment.systemPackages = with pkgs; [
    wget
    curl
    ripgrep
  ];
  programs = {
    # direnv?
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    nix-ld.enable = true; # https://github.com/nix-community/nix-ld
    less = {
      enable = true;
      # https://ascending.wordpress.com/2011/02/11/unix-tip-make-less-more-friendly/
      # https://www.topbug.net/blog/2016/09/27/make-gnu-less-more-powerful/
      envVariables = {
        LESS = lib.concatStrings [
          "--quit-if-one-screen "
          "--ignore-case "
          "--long-prompt "
          "--raw-control-chars " # raw ANSI colors
          "--hilite-unread " # first unread line after forward screen
          "--tabs=4 "
          "--no-init " # Don't use termcap init/deinit strings.
        ];
        # Render colors
        # TODO: Figure out how to represent those termcap sequences properly.
        # LESS_TERMCAP_mb="\\e[1;31m";     # begin bold
        # LESS_TERMCAP_md="\\e[1;36m";     # begin blink
        # LESS_TERMCAP_me="\\e[0m";        # reset bold/blink
        # LESS_TERMCAP_so="\\e[01;44;33m"; # begin reverse video
        # LESS_TERMCAP_se="\\e[0m";        # reset reverse video
        # LESS_TERMCAP_us="\\e[1;32m";     # begin underline
        # LESS_TERMCAP_ue="\\e[0m";        # reset underline
      };
    };

    git.enable = true;
    htop.enable = true;
    bat.enable = true;
    bandwhich.enable = true;

    fish.enable = true;
    command-not-found.enable = false;
    #nix-index.enable = true;

    nano.enable = false;
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  services.openssh.enable = lib.mkDefault false;
  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     PasswordAuthentication = false;
  #     PermitRootLogin = "no";
  #   };
  # };
}
