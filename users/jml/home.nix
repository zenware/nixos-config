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
    #nheko.settings = true;

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

  # TODO: figure out how to get config.programs.<name>.enable style
  # internal references inside this file.
  # There's some quirks with how this is used in lib/default.nix
  programs.jujutsu = {
    enable = true;
    #enableFishIntegration = true;
    settings = {
      user = {
        name = "Jay Looney";
        email = "jay.m.looney@gmail.com";
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Jay Looney";
        email = "jay.m.looney@gmail.com";
      };

      # Aliases Inspired by the following:
      # https://joel-hanson.github.io/posts/05-useful-git-aliases-for-a-productive-workflow/
      # https://gist.github.com/mwhite/6887990
      aliases = {
        la = "!git config -l | grep alias | cut -c 7-";
        s = "status -s";
        co = "checkout";
        cob = "checkout -b";
        del = "branch -D";
        ol = "log --oneline";

        br = "branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate";
        save = "!git add -A && git commit -m 'chore: commit save point'";
        undo = "reset HEAD~1 --mixed";
        done = "!git push origin HEAD";
        lg = "!git log --pretty=format:\"%C(magenta)%h%Creset -%C(red)%d%Creset %s %C(dim green)(%cr) [%an]\" --abbrev-commit -30";
        a = "add";
        ap = "add -p";
      };

      push.default = "simple";
      credential.helper = "cache --timeout=7200";
      init.defaultBranch = "main";
      log.decorate = "full";
      log.date = "iso";
      merge.conflictStyle = "diff3";
    };
    # Cribbed from: https://github.com/gitattributes/gitattributes
    attributes = [
      # Auto detect files and perform LF normalization
      "* text=auto"
      # Documents
      "*.bibtex text diff=bibtex"
      "*.doc      diff=astextplain"
      "*.DOC      diff=astextplain"
      "*.docx     diff=astextplain"
      "*.DOCX     diff=astextplain"
      "*.dot      diff=astextplain"
      "*.DOT      diff=astextplain"
      "*.pdf      diff=astextplain"
      "*.PDF      diff=astextplain"
      "*.rtf      diff=astextplain"
      "*.RTF      diff=astextplain"
      "*.md       text diff=markdown"
      "*.mdx      text diff=markdown"
      "*.tex      text diff=tex"
      "*.adoc     text"
      "*.textile  text"
      "*.mustache text"
      "*.csv      text eol=crlf"
      "*.tab      text"
      "*.tsv      text"
      "*.txt      text"
      "*.sql      text"
      "*.epub     diff=astextplain"

      # Graphics
      "*.png      binary"
      "*.jpg      binary"
      "*.jpeg     binary"
      "*.gif      binary"
      "*.tif      binary"
      "*.tiff     binary"
      "*.ico      binary"
      # SVG treated as text by default.
      "*.svg      text"
      # If you want to treat it as binary,
      # use the following line instead.
      # *.svg    binary
      "*.eps      binary"

      # Scripts
      "*.bash     text eol=lf"
      "*.fish     text eol=lf"
      "*.ksh      text eol=lf"
      "*.sh       text eol=lf"
      "*.zsh      text eol=lf"
      # These are explicitly windows files and should use crlf
      "*.bat      text eol=crlf"
      "*.cmd      text eol=crlf"
      "*.ps1      text eol=crlf"

      # Serialisation
      "*.json     text"
      "*.toml     text"
      "*.xml      text"
      "*.yaml     text"
      "*.yml      text"

      # Archives
      "*.7z       binary"
      "*.bz       binary"
      "*.bz2      binary"
      "*.bzip2    binary"
      "*.gz       binary"
      "*.lz       binary"
      "*.lzma     binary"
      "*.rar      binary"
      "*.tar      binary"
      "*.taz      binary"
      "*.tbz      binary"
      "*.tbz2     binary"
      "*.tgz      binary"
      "*.tlz      binary"
      "*.txz      binary"
      "*.xz       binary"
      "*.Z        binary"
      "*.zip      binary"
      "*.zst      binary"

      # Text files where line endings should be preserved
      "*.patch    -text"

      # Exclude files from exporting
      ".gitattributes export-ignore"
      ".gitignore     export-ignore"
      ".gitkeep       export-ignore"
    ];
    # TODO: Merge Gitignores from here: https://github.com/github/gitignore/tree/main/Global
    ignores = [
      "*~"
      "*.swp"
    ];
  };

  programs.emacs = {
    enable = true;
    # package = (pkgs.emacs30.pkgs.withPackages (epkgs: [
    #   epkgs.treesit-grammars.with-grammars (grammars: [
    #     grammars.tree-sitter-bash
    #   ])
    #   epkgs.pretty-sha-path
    # ]));
    extraConfig = ''
      (setq standard-indent 2)
    '';
  };

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;  # mutually exclusive to programs.vscode.profiles
    profiles.default.userSettings = {
      "[nix]"."editor.tabSize" = 2;
    };
  };
  # services.podman.enable = true;
}
