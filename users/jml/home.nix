{
  username,
  pkgs,
  lib,
  inputs,
  ...
}:
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
  home.packages =
    with pkgs;
    [ ]
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
        settings = {
          "widget.disable-workspace-management" = true;
        };
        search = {
          force = true;
          default = "ddg"; # DuckDuckGo
        };
      };
    };
  };

  # TODO: figure out how to get config.programs.<name>.enable style
  # internal references inside this file.
  # There's some quirks with how this is used in lib/default.nix
  # TODO: Use mergiraf for conflict resolution in jj too.
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

  # TODO: Configure Mergiraf
  # https://mergiraf.org/introduction.html
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
      # NOTE: Initially diff3 was for me, now it's for me and mergiraf automation.
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

  # TODO: Implement support for at least
  # Nix, Python, Rust, Golang
  # TODO: Sort out why TF, `.nix` files tabs are cooked in neovim rn.
  # It corrects things on document save, but this line for example started with an 8-long tabstop
  programs.nvf = {
    enable = true;
    # When using the Home-Manager Module for nvf, the settings go into the following attribute set.
    # https://notashelf.github.io/nvf/index.xhtml#sec-hm-flakes
    settings.vim = {
      viAlias = true;
      vimAlias = true;

      # TODO: For some reason spellcheck is having a very difficult time getting
      # a wordlist.
      #spellcheck = {
      #  enable = true;
      #  programmingWordlist.enable = true;
      #};

      lsp = {
        enable = true;
        formatOnSave = true;
        lspkind.enable = false;
        lightbulb.enable = true;
        lspsaga.enable = false;
        trouble.enable = true;
        lspSignature.enable = false;
        otter-nvim.enable = true;
        nvim-docs-view.enable = true;
      };

      languages = {
        enableDAP = true;
        enableExtraDiagnostics = true;
        enableFormat = true;
        enableTreesitter = true;

        nix = {
          enable = true;
          lsp.enable = true;
          lsp.server = "nixd";
          extraDiagnostics.enable = true;
          format.enable = true;
          format.type = "nixfmt";
          treesitter.enable = true;
        };
        markdown.enable = true;
        typst.enable = true;

        assembly.enable = true;
        bash.enable = true;
        clang.enable = true;

        python.enable = true;
        rust = {
          enable = true;
          # TODO: null_ls is now deprecated.
          # https://github.com/NotAShelf/nvf/issues/1175
          # https://github.com/NotAShelf/nvf/blob/main/.github/CONTRIBUTING.md
          crates.enable = true;
        };
        go.enable = true;
        zig.enable = true;

        ts.enable = true;
        html.enable = true;
        css.enable = true;
        sql.enable = true;
      };

      visuals = {
        nvim-scrollbar.enable = true; # Configurable Visual Scrollbar (Can pair with Cursor, ALE, Diagnostics, Gitsigns, and hlslens)
        nvim-web-devicons.enable = true; # Nerdfont Icons for use by other plugins
        nvim-cursorline.enable = true; # Highlight Words & Lines on the cursor
        cinnamon-nvim.enable = true; # Smooth Scrolling for any movement command.
        fidget-nvim.enable = true; # UI for Notifications & LSP Progress Messages

        highlight-undo.enable = true; # Highlight changed text after any non-insert actions
        indent-blankline.enable = true; # Indentation Guides
      };

      statusline = {
        lualine = {
          # Fancy Status Line
          enable = true;
          theme = "catppuccin";
        };
      };

      theme = {
        enable = true;
        name = "catppuccin";
        style = "mocha";
        transparent = false;
      };

      autopairs.nvim-autopairs.enable = true; # Pair up ", {, (, etc.
      # blink-cmp is a compiled rust binary while nvim-cmp is a pure lua plugin...
      autocomplete.blink-cmp.enable = true;
      # Code Snippets Engine /w support for Lua, VSCode, and SnipMate snippets.
      snippets.luasnip.enable = true;

      filetree.neo-tree.enable = true; # Filesystem tree sidebar...
      tabline.nvimBufferline.enable = true; # Shows buffers as tabs at the top.
      treesitter.context.enable = true;
      binds = {
        whichKey.enable = true; # Shows your available keybindings in a popup
        cheatsheet.enable = true; # Searchable in-editor cheatsheet that uses Telescope
      };
      telescope.enable = true; # Fuzzy Finder, central to many other plugins.

      git = {
        enable = true;
        gitsigns.enable = true; # Git Info in Buffers + Gutters
        gitsigns.codeActions.enable = false;
        neogit.enable = true; # Interactive Git
      };

      # TODO: Consider switching to `minimap-nvim` for rust-based minimap.
      # codewindow may be tightly integrated with treesitter though...
      minimap.codewindow.enable = true;
      dashboard.alpha.enable = true; # Greeter
      notify.nvim-notify.enable = true; # Fancy Configurable Notification Manager
      projects.project-nvim.enable = true;

      utility = {
        ccc.enable = true; # Color Picker
        diffview-nvim.enable = true;
        icon-picker.enable = true;
        surround.enable = true; # Change Surrounding Delimiter pairs `ysiw)`
        leetcode-nvim.enable = true; # Allow solving LeetCode problems directly inside neovim
        multicursors.enable = true; # Edit with multiple cursors simultaneously
        smart-splits.enable = true; # Split-Pane Management
        undotree.enable = true; # Undo history visualizer
        nvim-biscuits.enable = true; # Shows the start of a code block from the bottom

        motion = {
          # NOTE: https://github.com/smoka7/hop.nvim
          hop.enable = true; # EasyMotion like, allowing you to jump anywhere in the document with as few keystrokes as possible
          leap.enable = true; # Jump to anywhere visible
          # TODO: I sort of hate how precognition injects itself in virtual
          # lines, but I do like that it can be used to give a reminder.
          precognition.enable = false; # Helps with discovering motions to navigate your current buffer
        };
        images.img-clip.enable = true;
      };

      # TODO: Get Obsidian Working.
      notes = {
        # obsidian.enable = true; # neovim fails to build with this enabled.
        mind-nvim.enable = true;
        todo-comments.enable = true;
      };

      terminal = {
        toggleterm = {
          enable = true;
          lazygit.enable = true;
        };
      };

      ui = {
        borders.enable = true;
        noice.enable = true;
        colorizer.enable = true;
        modes-nvim.enable = false; # this looks terrible with catppuccin
        illuminate.enable = true;
        breadcrumbs = {
          enable = true;
          navbuddy.enable = true;
        };
        smartcolumn = {
          enable = true;
          setupOpts.custom_colorcolumn = {
            nix = "110";
            ruby = "120";
            java = "130";
            go = [
              "90"
              "130"
            ];
          };
        };
        fastaction.enable = true;
      };

      assistant = {
        chatgpt.enable = false;
        copilot = {
          enable = false;
          cmp.enable = true;
        };
        codecompanion-nvim.enable = false;
        # avante-nvim.enable = true;
      };

      session.nvim-session-manager.enable = true; # Save sessions to reopen later
      gestures.gesture-nvim.enable = false; # mouse gesture support?
      comments.comment-nvim.enable = true; # Fancy commenting
      presence.neocord.enable = true; # Discord Rich Presence
    };
  };

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true; # mutually exclusive to programs.vscode.profiles
    profiles.default.userSettings = {
      "[nix]"."editor.tabSize" = 2;
    };
  };
  # services.podman.enable = true;
}
