{
  config,
  inputs,
  username ? "jml",
  pkgs,
  lib,
  ...
}:
let
  desktop = config.zw.home.desktop.enable;
  rustTools = with pkgs; [
    cargo
    rustc
    rustfmt
    clippy
  ];
  rustowlPackages = inputs.rustowl.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  # NOTE: This file contains options that resolve under home-manager.users.<username>.
  imports = [
    ./options.nix
    ./email-linux.nix
  ];

  home = {
    inherit username;
    stateVersion = "25.05";
    sessionVariables = {
      EDITOR = "hx";
      RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
    };

    homeDirectory =
      if pkgs.stdenv.hostPlatform.isLinux then
        lib.mkDefault "/home/${username}"
      else if pkgs.stdenv.hostPlatform.isDarwin then
        lib.mkDefault "/Users/${username}"
      else
        abort "Unsupported OS";
  };
  home.packages =
    with pkgs;
    [
      devenv
      nixd
      nixfmt
      rustowlPackages.rustowl
    ]
    ++ rustTools
    # linux only
    # TODO: Add a test for linux + desktop environment
    ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      cfspeedtest
      helix
    ])
    # linux + desktop manager
    #++ (lib.optionals (pkgs.stdenv.HostPlatform.isLinux && osConfig.services.desktopManager.enabled != null)
    #[
    #  firefox
    #])
    # darwin only
    ++ (lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      cfspeedtest
      ripgrep
    ]);

  programs = {
    home-manager.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fish.enable = true;
    bat.enable = true;
    fzf.enable = true;
    jq.enable = true;
    btop.enable = true;
    zellij.enable = true;

    # Matrix Chat Apps
    element-desktop.enable = desktop;
    #nheko.settings = true;

    # Additions from Windows
    obsidian.enable = desktop;
    keepassxc.enable = desktop;
    #wezterm.enable = true;
    gpg.enable = true;
    # onedrive.enable = true;
    # thunderbird.enable = true;
    # vdirsyncer.enable = true;
    nushell.enable = true;
    helix.enable = true;
    zoxide.enable = true;
    fd.enable = true;

    difftastic.enable = true;
    difftastic.git.enable = true;
    difftastic.git.mode = "both";
    mergiraf = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
    };
    obs-studio.enable = desktop && pkgs.stdenv.hostPlatform.isLinux; # TODO: Issue on aarch64-darwin;
    ghostty.enable = desktop; # TODO: Issue on aarch64-darwin;
    ghostty.package =
      if pkgs.stdenv.hostPlatform.isLinux then
        pkgs.ghostty
      else if pkgs.stdenv.hostPlatform.isDarwin then
        pkgs.ghostty-bin
      else
        abort "Unsupported OS";
    ghostty.enableBashIntegration = true;
    ghostty.enableZshIntegration = true;
    ghostty.enableFishIntegration = true;
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

  programs.doom-emacs = {
    enable = true;
    doomDir = ./doom;
    experimentalFetchTree = true;
    extraBinPackages = [
      pkgs.git
      pkgs.ripgrep
      pkgs.fd
      pkgs.nixd
      pkgs.nixfmt
      pkgs.rust-analyzer
      rustowlPackages.rustowl
    ]
    ++ rustTools;
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.nixfmt
      (epkgs.trivialBuild {
        pname = "rustowl";
        inherit (rustowlPackages.rustowl) version;
        src = inputs.rustowl.inputs.rustowl;
        packageRequires = [ epkgs.lsp-mode ];
      })
    ];
  };

  # TODO: Compare some bulkier plugins with 'mini.nvim' replacements.
  # mini.nvim is also configurable through nvf under it's own namespace rather than functionality-named namespaces.
  # https://www.reddit.com/r/neovim/comments/1o6jjw0/my_review_of_minivim/
  programs.nvf = {
    enable = true;
    # When using the Home-Manager Module for nvf, the settings go into the following attribute set.
    # https://notashelf.github.io/nvf/index.xhtml#sec-hm-flakes
    settings.vim = {
      viAlias = true;
      vimAlias = true;

      extraPackages = rustTools ++ [ rustowlPackages.rustowl ];
      extraPlugins.rustowl = {
        package = rustowlPackages.rustowl-nvim;
        setup = ''
          require("rustowl").setup({
            auto_enable = true,
            client = { cmd = { "${rustowlPackages.rustowl}/bin/rustowl" } },
          })
        '';
      };
      spellcheck.enable = true;
      # ponytail: bundled English dictionary; no runtime wordlist downloads.
      spellcheck.languages = [ "en" ];
      autocmds = [
        {
          event = [ "FileType" ];
          pattern = [
            "nix"
            "terraform"
            "hcl"
          ];
          command = "setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2";
        }
      ];

      visuals = {
        nvim-scrollbar.enable = true; # Configurable Visual Scrollbar (Can pair with Cursor, ALE, Diagnostics, Gitsigns, and hlslens)
        nvim-web-devicons.enable = true; # Nerdfont Icons for use by other plugins
        nvim-cursorline.enable = true; # Highlight Words & Lines on the cursor
        cinnamon-nvim.enable = true; # Smooth Scrolling for any movement command.
        fidget-nvim.enable = true; # UI for Notifications & LSP Progress Messages

        highlight-undo.enable = true; # Highlight changed text after any non-insert actions
        indent-blankline.enable = true; # Indentation Guides
      };

      statusline.lualine = {
        enable = true;
        #setupOpts.options.theme = lib.mkForce "catppuccin";
        integrations.breadcrumbs = {
          nvim-navic.enable = true;
          navbuddy.enable = true;
        };
      };

      theme = {
        enable = true;
        name = lib.mkForce "catppuccin";
        style = "mocha";
        transparent = false;
      };
      autocomplete.blink-cmp = {
        enable = true;
        friendly-snippets.enable = true;
      };
      autopairs.nvim-autopairs.enable = true; # Pair up ", {, (, etc.
      binds = {
        cheatsheet.enable = true; # Searchable in-editor cheatsheet that uses Telescope
        hardtime-nvim.enable = true; # Prevents you from using arrow keys and other "bad habits"
        whichKey.enable = true; # Shows your available keybindings in a popup
      };
      clipboard.enable = true; # Clipboard Integration
      dashboard.alpha.enable = true; # Greeter
      debugger.nvim-dap.enable = true; # Debugger
      debugger.nvim-dap.ui.enable = true; # Debugger UI
      diagnostics = {
        enable = true;
        presets = {
          deadnix.enable = true;
          statix.enable = true;
        };
      };
      filetree.neo-tree.enable = true; # Filesystem tree sidebar.
      formatter.conform-nvim = {
        enable = true;
        presets = {
          # Typescript
          biome.enable = true;
          biome-check.enable = true;
          biome-organize-imports.enable = true;
          # Golang
          gofumpt.enable = true; # More-Strict Superset of gofmt
          goimports.enable = true;
          # Nix-lang
          nixfmt.enable = true;
          # Python
          ruff.enable = true;
          ruff-fix.enable = true;
          ruff-organize-imports.enable = true;
          # Rust
          rustfmt.enable = true;
        };
      };
      git = {
        enable = true;
        git-conflict.enable = true;
        gitlinker-nvim.enable = true; # Copy GitHub/GitLab/Bitbucket links to clipboard
        gitsigns.enable = true; # Git Info in Buffers + Gutters
        gitsigns.codeActions.enable = false;
        neogit.enable = true; # Interactive Git
        octo-nvim.enable = true; # GitHub Integration
      };
      languages = {
        enableDAP = true;
        enableExtraDiagnostics = true;
        enableFormat = true;
        enableTreesitter = true;

        nix = {
          enable = true;
          lsp.enable = true;
          lsp.servers = [ "nixd" ];
          extraDiagnostics.enable = true;
          format.enable = true;
          format.type = [ "nixfmt" ];
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
          extensions.crates-nvim.enable = true;
        };
        go.enable = true;
        # zig.enable = true; # TODO: Add Zig packages?

        typescript.enable = true;
        #html.enable = true; # TODO: Add HTML packages?
        css.enable = true;
        sql.enable = true;
      };
      lazy.enable = true; # Lazy Load when possible.
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
        servers.rust-analyzer.settings.rust-analyzer.cargo.sysrootSrc = "${pkgs.rustPlatform.rustLibSrc}";
      };

      # Code Snippets Engine /w support for Lua, VSCode, and SnipMate snippets.
      snippets.luasnip.enable = true;

      tabline.nvimBufferline.enable = true; # Shows buffers as tabs at the top.
      treesitter.context.enable = true;
      telescope.enable = true; # Fuzzy Finder, central to many other plugins.
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
          precognition.enable = false; # Helps with discovering motions to navigate your current buffer
        };
        images.img-clip.enable = true;
      };

      notes = {
        # obsidian.enable = true; # neovim fails to build with this enabled.
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

      session.nvim-session-manager.enable = true; # Save sessions to reopen later
      comments.comment-nvim.enable = true; # Fancy commenting
      presence.neocord.enable = true; # Discord Rich Presence
    };
  };

  # services.podman.enable = true;

  # TODO: Consider configuring MCP servers. and local-ai
  # TODO:
  # services.home-manager.autoUpgrade.useFlake = true;
  # services.home-manager.autoUpgrade.flakeDir = <here-ish>;
  # TODO: Manually import necessary modules.
  # home-manager.minimal = true;

  # TODO: A weird amount of work if I actually care to get Zed running.
  # https://wiki.nixos.org/wiki/Zed
  targets.genericLinux.nixGL.vulkan.enable = desktop && pkgs.stdenv.hostPlatform.isLinux;
  programs.zed-editor = {
    enable = desktop;
    extensions = [
      "nix"
      "toml"
      #"rust"
      "basedpyright"
      "ruff"
    ];
    extraPackages = with pkgs; [
      basedpyright
      nixd
      ruff
      #rust-analyzer
      #rustc
    ];
    userSettings = {
      vim_mode = true;
      lsp.nixd.binary.path = "${pkgs.nixd}/bin/nixd";
      languages = {
        Nix.language_servers = [ "nixd" ];
        Python = {
          language_servers = [
            "basedpyright"
            "!pyright"
          ];
        };
      };
    };
  };
}
