{ username, pkgs, lib, ... }:
{
  nixpkgs.config.allowUnfree = true;
  # The following line is needed if I start using hyprland Home Manager Module
  #wayland.windowManager.sway.systemd.enable = false;
  # NOTE: This file contains options that resolve under home-manager.users.<username>
  home = {
    inherit username;
    stateVersion = "25.05";
    sessionVariables = {
      EDITOR = "hx";
    };
    
    homeDirectory = 
      if pkgs.stdenv.isLinux then
        lib.mkDefault "/home/${username}"
      else if pkgs.stdenv.isDarwin then
        lib.mkDefault "/Users/${username}"
      else
        abort "Unsupported OS";
  };
  home.packages = with pkgs; [ ]
  # linux only
  # TODO: Add a test for linux + desktop environment
  ++ (lib.optionals pkgs.stdenv.isLinux [
    cfspeedtest
    helix
    nil
  ])
  # linux + desktop manager
  #++ (lib.optionals (pkgs.stdenv.isLinux && osConfig.services.desktopManager.enabled != null)
  #[
  #  firefox
  #])
  # darwin only
  ++ (lib.optionals pkgs.stdenv.isDarwin [
    cfspeedtest
    ripgrep
  ]);

  programs = {
    fish.enable = true;
    home-manager.enable = true;
    bat.enable = true;
    fzf.enable = true;
    jq.enable = true;
    btop.enable = true;
    zellij.enable = true;

    # Matrix Chat Apps
    element-desktop.enable = true;
    nheko.settings = true;

    # Additions from Windows
    obsidian.enable = true;
    obs-studio.enable = true;
    keepassxc.enable = true;
    wezterm.enable = true;
    ghostty.enable = true;
    gpg.enable = true;
    # onedrive.enable = true;
    # thunderbird.enable = true;
    # vdirsyncer.enable = true;
    nushell.enable = true;
    helix.enable = true;
    zoxide.enable = true;
    fd.enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      line_break.disabled = true;
      aws.disabled = true;
      gcloud.disabled = true;
    };
  };

  programs.firefox = {
    enable = true;
    policies = {
      DontCheckDefaultBrowser = true;
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxScreenshots = true;

      UserMessaging = {
        UrlbarInterventions = false;
        SkipOnboarding = true;
      };
      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };
      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      
      Homepage.StartPage = "previous-session";
      FirefoxHome = {
        Search = true;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = false;
      };

      Handlers.schemes.element = {
        action = "useSystemDefault";
        ask = false;
      };

      Preferences = {
        "browser.urlbar.suggest.searches" = true;
        "browser.tabs.tabMinWidth" = 75;

        "browser.aboutConfig.showWarning" = false;
        "browser.warnOnQuitShortcut" = false;

        "browser.tabs.loadInBackground" = true;
        "browser.in-content.dark-mode" = true;
      };
    };
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings =  {
          "widget.disable-workspace-management" = true;
        };
        search = {
          force = true;
          default = "ddg";  # DuckDuckGo
        };
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "Jay Looney";
    userEmail = "jay.m.looney@gmail.com";
    aliases = {
      ol = "log --oneline";
    };
    ignores = [ "*~" "*.swp" ];
    extraConfig = {
      push.default = "simple";
      credential.helper = "cache --timeout=7200";
      init.defaultBranch = "main";
      log.decorate = "full";
      log.date = "iso";
      merge.conflictStyle = "diff3";
    };
  };

  # services.podman.enable = true;
}
