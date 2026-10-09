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
  # TODO: Completely eradicate cfspeedtest
  # Add iperf3 to base config of all my machines?
  # Replace cfspeedtest with a different/better? cli speedtest tool?
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

  programs.nvf = {
    enable = true;
    settings.vim = {
      viAlias = true;
      vimAlias = true;
      globals.editorconfig = true;
      options = {
        cursorline = true;
        foldlevel = 99;
        foldlevelstart = 99;
      };

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

      # TODO: If I have luasnip enabled, do I need to enable friendly-snippets here?
      autocomplete.blink-cmp = {
        enable = true;
        friendly-snippets.enable = true;
      };
      autopairs.nvim-autopairs.enable = true; # Pair up ", {, (, etc.
      binds.hardtime-nvim.enable = true; # Prevents you from using arrow keys and other "bad habits"
      clipboard.enable = true; # Clipboard Integration
      dashboard.alpha.enable = true; # Greeter
      debugger.nvim-dap = {
        enable = true;
        ui.enable = true;
        adapters = lib.genAttrs [ "pwa-node" "node" ] (_: {
          type = "server";
          host = "127.0.0.1";
          port = "\${port}";
          executable = {
            command = lib.getExe pkgs.vscode-js-debug;
            args = [
              "\${port}"
              "127.0.0.1"
            ];
          };
        });
        # Project launch profiles are read from .vscode/launch.json on demand.
        configurations =
          lib.genAttrs
            [
              "javascript"
              "javascriptreact"
              "typescript"
              "typescriptreact"
            ]
            (_: [
              {
                name = "Attach to Node.js";
                type = "pwa-node";
                request = "attach";
                processId = lib.generators.mkLuaInline ''require("dap.utils").pick_process'';
                cwd = "\${workspaceFolder}";
              }
            ]);
      };
      diagnostics.enable = true;
      filetree.neo-tree = {
        enable = true;
        setupOpts.window.position = "right";
      };
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
        gitlinker-nvim.enable = true; # Copy GitHub/GitLab/Bitbucket links to clipboard
        gitsigns.enable = true; # Git Info in Buffers + Gutters
        neogit.enable = true; # Interactive Git
        neogit.setupOpts.integrations.diffview = true;
        octo-nvim.enable = true; # GitHub Integration
      };
      languages = {
        enableDAP = true;
        enableExtraDiagnostics = true;
        enableFormat = true;
        enableTreesitter = true;

        nix = {
          enable = true;
          lsp.servers = [ "nixd" ];
          format.type = [ "nixfmt" ];
        };
        #markdown.enable = true; markdown-oxide specified elsewhere.
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

        typescript = {
          enable = true;
          lsp.servers = [ "typescript-go" ];
        };
        #html.enable = true; # TODO: Add HTML packages?
        css.enable = true;
        sql.enable = true;
      };
      lsp = {
        enable = true;
        formatOnSave = true;
        lightbulb.enable = true;
        otter-nvim.enable = true;
        presets = {
          harper.enable = true; # LSP English-only Grammar
          markdown-oxide.enable = true; # Markdown LSP, Obsidian-Like
          ruff.enable = true; # Python LSP
          ty.enable = true; # Python LSP
        };
        # Extend the JS/TS filetypes supplied by the language module to React buffers.
        servers.typescript-go.filetypes = [
          "javascriptreact"
          "typescriptreact"
        ];
        servers.ruff.filetypes = [ "python" ];
        servers.ty.filetypes = [ "python" ];
        servers.markdown-oxide.filetypes = [ "markdown" ];
        servers.rust-analyzer.settings.rust-analyzer.cargo.sysrootSrc = "${pkgs.rustPlatform.rustLibSrc}";
        trouble.enable = true;
      };
      mini = {
        clue.enable = true; # whichKey replacement: Shows keybinding hints in a popup
        icons.enable = true; # nvim-web-devicons replacement: mocks out the methods to improve compatibility
        sessions.enable = true; # Session Management
        starter.enable = true;
        statusline.enable = true; # lualine replacement: Less complex statusline
        tabline.enable = true; # nvimBufferline replacement, I do get value from this with multiple buffers open
      };

      # TODO: Not sure I care about harpoon at all.
      # navigation.harpoon.enable = true; # Quick Navigation to Files, Buffers, and Bookmarks
      notes = {
        # obsidian.enable = true; # neovim fails to build with this enabled.
        todo-comments.enable = true;
      };

      notify.nvim-notify.enable = true; # Notification backend for Noice.
      presence.cord-nvim.enable = true; # Discord Rich Presence

      spellcheck = {
        enable = true;
        languages = [ "en" ];
        programmingWordlist.enable = true;
      };
      telescope.enable = true; # Fuzzy Finder, central to many other plugins.
      terminal.toggleterm.enable = true;
      theme = {
        enable = true;
        name = "catppuccin";
        style = "mocha";
        transparent = false;
      };
      treesitter.context.enable = true;
      treesitter.fold = true;
      ui = {
        borders.enable = true;
        colorful-menu-nvim.enable = true;
        dropbar-nvim.enable = true;
        illuminate.enable = true;
        noice.enable = true;
        nvim-highlight-colors.enable = true; # Preview color literals inline.
        smartcolumn.enable = true;
      };
      undoFile.enable = true;
      utility = {
        auto-indent-nvim.enable = true; # VSCode-like tab indentation? Probably there's a better solution.
        ccc.enable = true; # Color Picker
        crazy-coverage.enable = true; # Code Coverage Visualizer
        csvview.enable = true; # CSV Viewer
        direnv.enable = true; # Consider nix-develop only if it adds something really useful.
        grug-far-nvim.enable = true; # Find and Replace Tool
        # NOTE: Guess Indent doesn't exist?
        #guess-indent.enable = true; # Automatic indentation detection, I think I don't like this premise. Probably prefer defined indentation.
        icon-picker.enable = true; # Nerdfonts Icon Picker
        images = {
          image-nvim.enable = true; # Kitty Image Protocol Support
          img-clip.enable = true; # Clipboard Image Support
        };
        # TODO: I kind of want this leetcode plugin for hackerrank/projecteuler/AdventOfCode/etc.
        # Perhaps I should implement that myself as a fun open source project.
        leetcode-nvim.enable = true; # Allow solving LeetCode problems directly inside neovim
        mkdir.enable = true; # Create directories on the fly when saving files
        motion = {
          leap.enable = true; # Jump to anywhere visible
        };
        multicursors.enable = true; # Edit with multiple cursors simultaneously
        nvim-biscuits.enable = true; # Visually clarifies the end of a block-context, Actually quite love this.
        outline.aerial-nvim.enable = true; # Show a sidebar with the outline of the current buffer, code-symbol navigation.
        # TODO: add 'markdown-render.nvim' for live markdown rendering.
        # NOTE: If smart-paste works it will solve a longstanding frustration I have with forgetting to `:set paste`, `:set nopaste`
        smart-paste-nvim.enable = true; # Paste text without losing indentation, I think this is a good idea.
        smart-splits.enable = true; # Split-Pane Management
        surround.enable = true; # Change Surrounding Delimiter pairs `ysiw)`
        undotree.enable = true; # Undo history visualizer
      };
      visuals = {
        blink-indent.enable = true; # Indentation guides.
        cinnamon-nvim.enable = true; # Smooth Scrolling for any movement command.
        highlight-undo.enable = true; # Highlight changed text after any non-insert actions
        hlargs-nvim.enable = true;
        nvim-scrollbar.enable = true; # Configurable Visual Scrollbar (Can pair with Cursor, ALE, Diagnostics, Gitsigns, and hlslens)
        rainbow-delimiters.enable = true; # Colorize Delimiters # Occasionally do LISP/Scheme things and this is handy.
        twilight-nvim.enable = true; # Tree-Sitter Aware Code Dimming
      };
    };
  };
  # Python Support built into Zed with ty + ruff - How do I make sure there's Debugger, etc.
  # Rust support built in, CodeLLDB Debugger
  targets.genericLinux.nixGL.vulkan.enable = desktop && pkgs.stdenv.hostPlatform.isLinux;
  # TODO: Consider what needs to be in `nix-ld` for LSP support.
  # https://wiki.nixos.org/wiki/Zed#Nix-ld_(recommended)
  # https://github.com/search?q=lang%3Anix+zed-editor&type=code
  programs.zed-editor = {
    enable = desktop;
    # TODO: Automate catppuccin theme and icons
    extensions = [
      "nix"
      "toml"
      "typst"
    ];
    # TODO: Add gopls, and anything else needed...
    extraPackages = with pkgs; [
      nixd
    ];
    # TODO: Configure the programming languages I use in Zed just how I like them
    # Look to the extension store, and Zed's own documentation: https://zed.dev/docs/languages/python
    # As well as other NixOS Configs posted to GitHub
    #
    userSettings = {
      vim_mode = true;
      # TODO: Set rust-analyzer path?
      lsp.nixd.binary.path = "${pkgs.nixd}/bin/nixd";
      languages = {
        Nix.language_servers = [ "nixd" ];
        Python = {
          # Enable the Python Servers I care about
          language_servers = [
            "ty"
            "!basedpyright"
          ];
          # TODO: Quirk with building this line properly
          # the code_actions_on_format line needs to be as-written to get the right output shape.
          code_actions_on_format."source.organizeImports.ruff" = true;
          formatter.language_server.name = "ruff";
        };
      };
    };
  };
}
