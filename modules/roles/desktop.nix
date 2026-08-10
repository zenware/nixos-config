{
  # NOTE: The single module for all desktop concerns: session/compositor
  # choices, display manager, audio, fonts, portals, and the common desktop
  # userland. Hosts answer two questions:
  #   "does this host have a desktop environment?"  -> zw.desktop.enable
  #   "which sessions may the login screen launch?" -> zw.desktop.sessions
  flake.modules.nixos.desktop =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      cfg = config.zw.desktop;
      sessionEnabled = session: builtins.elem session cfg.sessions;
      custom-astronaut-theme = pkgs.sddm-astronaut.override {
        embeddedTheme = "pixel_sakura";
      };
    in
    {
      options.zw.desktop = {
        enable = lib.mkEnableOption "a graphical desktop environment";
        sessions = lib.mkOption {
          type = lib.types.listOf (
            lib.types.enum [
              "hyprland"
              "niri"
              "xfce"
              "gnome"
            ]
          );
          default = [ "niri" ];
          example = [
            "niri"
            "xfce"
          ];
          description = "Desktop sessions the login screen allows the user to launch.";
        };
        defaultSession = lib.mkOption {
          type = lib.types.enum [
            "hyprland"
            "niri"
            "xfce"
            "gnome"
          ];
          default = "niri";
          description = "Session the display manager preselects. Must be one of zw.desktop.sessions.";
        };
      };

      config = lib.mkIf cfg.enable (lib.mkMerge [
        {
          assertions = [
            {
              assertion = builtins.elem cfg.defaultSession cfg.sessions;
              message = "zw.desktop.defaultSession (${cfg.defaultSession}) must be one of zw.desktop.sessions";
            }
          ];
        }

        # Common desktop plumbing
        {
          services.xserver = {
            enable = true;
            xkb.layout = "us";
            displayManager.startx.enable = lib.mkDefault false;
          };

          # https://wiki.archlinux.org/title/XDG_Desktop_Portal#List_of_backends_and_interfaces
          services.dbus.enable = true;
          xdg.portal = {
            enable = true;
            extraPortals = with pkgs; [
              xdg-desktop-portal-gtk # Fallback for file picker, etc.
            ];
            xdgOpenUsePortal = true;
          };

          networking.networkmanager.enable = lib.mkDefault true;

          # Authentication Agent (polkit) - required for privilege escalation in GUI apps
          security.polkit.enable = lib.mkDefault true;

          # Keyring for storing secrets
          services.gnome.gnome-keyring.enable = true;

          # Thumbnail support for file managers
          services.tumbler.enable = true;

          environment.sessionVariables = {
            # Hint electron apps to use wayland
            NIXOS_OZONE_WL = "1";
          };

          environment.systemPackages = with pkgs; [
            brave
            libsecret # Used for the desktop KeepassXC integration.

            # System Utilities
            networkmanagerapplet # Tray Icon for managing network connections
            yubikey-personalization

            # Display Manager Configuration Tools (for laptops)
            wlr-randr # A CLI tool for configuring monitors on Wayland (e.g., Hyprland)
            pavucontrol # Graphical Volume Mixer (PulseAudio/PipeWire)
            # gnome.file-roller -- Just use tar
            feh # Simple image viewer (or a wayland alternative)
            clipman # Wayland clipboard manager

            # App Launchers
            rofi
            wofi
            fuzzel

            # Status bar (if not using compositors built-in)
            waybar

            # Wallpaper managers
            awww

            # File manager
            # TODO: Switch back to nautilus/gnome files?
            thunar
            thunar-volman # Removable Media
            gvfs # Trash support and more

            # Wayland Utilities
            wl-clipboard
            wlr-randr
            wayland-utils

            # Screenshot and screen recording
            grim
            slurp
            wf-recorder

            # Notification Daemon (choose one) - https://wiki.archlinux.org/title/Desktop_notifications
            mako
            # dunst

            # Clipboard manager
            cliphist
          ];

          # Enable dconf (System configuration database)
          # https://wiki.archlinux.org/title/GNOME#Configuration
          programs.dconf.enable = true;

          # NOTE: This is closer to being host-specific or at least, not necessary on every system which has a desktop environment.
          # udev rules for certain ahrdware (game controllers, etc.)
          # services.udev.packages = with pkgs; [ ]; # add any specific udev rules you need

          # Enable printing support (optional)
          services.printing.enable = lib.mkDefault true;

          # Scanner support (optional)
          services.saned.enable = lib.mkDefault false;

          # Flatpak support (optional)
          services.flatpak.enable = lib.mkDefault false;

          # Allow users to mount filesystems without root
          programs.fuse.userAllowOther = true;

          services.avahi.enable = lib.mkDefault true; # zeroconf/mDNS(.local)
        }

        # Audio
        {
          # For real-time audio/production consider: https://github.com/musnix/musnix
          security.rtkit.enable = lib.mkDefault true;
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            #jack.enable = true;
            wireplumber.enable = true;
          };
        }

        # Fonts
        {
          fonts = {
            enableDefaultPackages = true;
            packages = with pkgs; [
              atkinson-hyperlegible

              noto-fonts
              noto-fonts-cjk-sans
              noto-fonts-color-emoji
              liberation_ttf
              fira-code
              fira-code-symbols
              font-awesome

              nerd-fonts.fira-code
              nerd-fonts.jetbrains-mono
              nerd-fonts.iosevka
              # dejavu_fonts
            ];

            # TODO: Explore other default fonts, particularly atkinson-hyperlegible
            fontconfig = {
              defaultFonts = {
                serif = [ "Noto Serif" ];
                sansSerif = [ "Noto Sans" ];
                monospace = [ "FiraCode Nerd Font" ];
                emoji = [ "Noto Color Emoji" ];
              };
            };
          };
        }

        # Display manager (SDDM; GDM takes over if the gnome session is enabled)
        {
          environment.systemPackages = [
            (pkgs.catppuccin-sddm.override {
              flavor = "mocha";
              accent = "teal";
              font = "Noto Sans";
              fontSize = "9";
              #background = "${./wallpaper.png}";
              loginBackground = true;
            })
            custom-astronaut-theme
            # NOTE: Packages below here may be consumed by themes.
            pkgs.kdePackages.qtbase
            pkgs.kdePackages.qtwayland
            pkgs.kdePackages.qtmultimedia
          ];
          services.displayManager.defaultSession = cfg.defaultSession;

          # TODO: Figure out how to add a session selector to sddm-astronaut-theme.
          services.displayManager.sddm = {
            enable = true;
            package = pkgs.kdePackages.sddm;
            wayland.enable = true;
            #theme = "catppuccin-mocha-teal";
            theme = "sddm-astronaut-theme";
            extraPackages = [ custom-astronaut-theme ];
          };
        }

        # Session: hyprland
        (lib.mkIf (sessionEnabled "hyprland") {
          programs.hyprland = {
            enable = true;
            withUWSM = true;
            xwayland.enable = true;
          };

          xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

          xdg.portal.config.hyprland = {
            default = [
              "hyprland"
              "gtk"
            ];
            "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
          };

          environment.systemPackages = with pkgs; [
            xdg-desktop-portal-hyprland
            kitty # Hyprland default term
            # Hyprland-specific tools
            hyprpaper
            hypridle
            hyprlock
          ];

          programs.hyprlock.enable = true;
        })

        # Session: niri
        (lib.mkIf (sessionEnabled "niri") {
          # Opinionated Niri Setup - https://yalter.github.io/niri/Important-Software.html
          # Consider: https://github.com/sodiboo/niri-flake

          # NOTE: Rather than individual components, I'm going to start with a complete desktop shell if possible.
          # According to the docs there's a few options: https://yalter.github.io/niri/Getting-Started.html#desktop-environments
          # LXQt, many parts of XFCE, COSMIC + `cosmic-ext-extra-sessions`
          # And what I actually want to try out is one of DankMaterialShell or Noctalia
          programs.niri = {
            enable = true;
            package = pkgs.niri;
          };

          environment.systemPackages = with pkgs; [
            inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
            xwayland-satellite
            fuzzel
            kitty
            fastfetch
          ];

          services.displayManager.sessionPackages = [ pkgs.niri ];

          # Deploy ${./config.kdl} to `~/.config/niri/config.kdl`

          # Notification Daemon
          #services.mako.enable = true;
          #services.mako.settings.default-timeout = 3000;

          # Portal - https://wiki.archlinux.org/title/XDG_Desktop_Portal#List_of_backends_and_interfaces

          # Xwayland
          # https://github.com/Supreeeme/xwayland-satellite
          #programs.xwayland.enable = lib.mkDefault true;

          # Screencasting - https://yalter.github.io/niri/Screencasting.html
          # Needs D-Bus, pipewire, `xdg-desktop-portal-gnome`? Or a portal from the above table with screencasting support
        })

        # Session: xfce
        (lib.mkIf (sessionEnabled "xfce") {
          services.xserver.desktopManager = {
            xterm.enable = false;
            xfce.enable = true;
          };
        })

        # Session: gnome
        # NOTE: Enabling the gnome session replaces SDDM with GDM.
        (lib.mkIf (sessionEnabled "gnome") {
          services.desktopManager.gnome.enable = true;
          services.displayManager.sddm.enable = lib.mkForce false;

          services.xserver.displayManager.gdm = {
            enable = true;
            wayland = true;
          };

          environment.systemPackages = with pkgs; [
            gnome-tweaks
            dconf-editor
          ];

          environment.gnome.excludePackages = with pkgs; [
            gnome-music
            gnome-photos
            gnome-tour
            epiphany
            geary
          ];
        })
      ]);
    };
}
