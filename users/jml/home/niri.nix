{
  lib,
  osConfig,
  ...
}:
let
  action = name: {
    action.${name} = [ ];
  };
  directionalBinds =
    lib.genAttrs [
      "Mod+Left"
      "Mod+H"
    ] (_: action "focus-column-left")
    // lib.genAttrs [
      "Mod+Down"
      "Mod+J"
    ] (_: action "focus-window-down")
    // lib.genAttrs [
      "Mod+Up"
      "Mod+K"
    ] (_: action "focus-window-up")
    // lib.genAttrs [
      "Mod+Right"
      "Mod+L"
    ] (_: action "focus-column-right")
    // lib.genAttrs [
      "Mod+Ctrl+Left"
      "Mod+Ctrl+H"
    ] (_: action "move-column-left")
    // lib.genAttrs [
      "Mod+Ctrl+Down"
      "Mod+Ctrl+J"
    ] (_: action "move-window-down")
    // lib.genAttrs [
      "Mod+Ctrl+Up"
      "Mod+Ctrl+K"
    ] (_: action "move-window-up")
    // lib.genAttrs [
      "Mod+Ctrl+Right"
      "Mod+Ctrl+L"
    ] (_: action "move-column-right")
    // lib.genAttrs [
      "Mod+Shift+Left"
      "Mod+Shift+H"
    ] (_: action "focus-monitor-left")
    // lib.genAttrs [
      "Mod+Shift+Down"
      "Mod+Shift+J"
    ] (_: action "focus-monitor-down")
    // lib.genAttrs [
      "Mod+Shift+Up"
      "Mod+Shift+K"
    ] (_: action "focus-monitor-up")
    // lib.genAttrs [
      "Mod+Shift+Right"
      "Mod+Shift+L"
    ] (_: action "focus-monitor-right")
    // lib.genAttrs [
      "Mod+Shift+Ctrl+Left"
      "Mod+Shift+Ctrl+H"
    ] (_: action "move-column-to-monitor-left")
    // lib.genAttrs [
      "Mod+Shift+Ctrl+Down"
      "Mod+Shift+Ctrl+J"
    ] (_: action "move-column-to-monitor-down")
    // lib.genAttrs [
      "Mod+Shift+Ctrl+Up"
      "Mod+Shift+Ctrl+K"
    ] (_: action "move-column-to-monitor-up")
    // lib.genAttrs [
      "Mod+Shift+Ctrl+Right"
      "Mod+Shift+Ctrl+L"
    ] (_: action "move-column-to-monitor-right");

  workspaceBinds = lib.listToAttrs (
    lib.concatMap (
      number:
      let
        workspace = toString number;
      in
      [
        {
          name = "Mod+${workspace}";
          value.action.focus-workspace = number;
        }
        {
          name = "Mod+Ctrl+${workspace}";
          value.action.move-column-to-workspace = number;
        }
      ]
    ) (lib.range 1 9)
  );
in
{
  stylix = {
    enable = true;
    inherit (osConfig.stylix) base16Scheme polarity;
  };

  programs.niri.settings = {
    spawn-at-startup = [
      { argv = [ "noctalia" ]; }
    ];

    window-rules = [
      {
        geometry-corner-radius = {
          top-left = 20.0;
          top-right = 20.0;
          bottom-right = 20.0;
          bottom-left = 20.0;
        };
        clip-to-geometry = true;
      }
      {
        matches = [ { app-id = "^dev\\.noctalia\\.Noctalia$"; } ];
        open-floating = true;
        default-column-width.fixed = 1080;
        default-window-height.fixed = 920;
      }
    ];

    debug.honor-xdg-activation-with-invalid-serial = [ ];

    layer-rules = [
      {
        matches = [ { namespace = "^noctalia-backdrop"; } ];
        place-within-backdrop = true;
      }
    ];

    switch-events.lid-close.action.spawn = [
      "noctalia"
      "msg"
      "session"
      "lock-and-suspend"
    ];

    binds =
      directionalBinds
      // workspaceBinds
      // {
        "Mod+Space".action."spawn-sh" = "noctalia msg panel-toggle launcher";
        "Mod+S".action."spawn-sh" = "noctalia msg panel-toggle control-center";
        "Mod+Comma".action."spawn-sh" = "noctalia msg settings-toggle";
        "Alt+Tab".action."spawn-sh" = "noctalia msg window-switcher";

        "Mod+Shift+Slash" = action "show-hotkey-overlay";
        "Mod+T" = {
          action.spawn = [ "ghostty" ];
          hotkey-overlay.title = "Open a Terminal: ghostty";
        };
        "Mod+D" = {
          action.spawn = [ "fuzzel" ];
          hotkey-overlay.title = "Run an Application: fuzzel";
        };
        "Super+Alt+L".action."spawn-sh" = "noctalia msg session lock";

        "Mod+Q" = {
          action.close-window = [ ];
          repeat = false;
        };
        "Mod+Page_Down" = action "focus-workspace-down";
        "Mod+Page_Up" = action "focus-workspace-up";
        "Mod+Ctrl+Page_Down" = action "move-column-to-workspace-down";
        "Mod+Ctrl+Page_Up" = action "move-column-to-workspace-up";

        "Mod+R" = action "switch-preset-column-width";
        "Mod+Shift+R" = action "switch-preset-window-height";
        "Mod+Ctrl+R" = action "reset-window-height";
        "Mod+F" = action "maximize-column";
        "Mod+Shift+F" = action "fullscreen-window";
        "Mod+Ctrl+F" = action "expand-column-to-available-width";
        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";
        "Mod+V" = action "toggle-window-floating";
        "Mod+Shift+V" = action "switch-focus-between-floating-and-tiling";

        "Print" = action "screenshot";
        "Ctrl+Print" = action "screenshot-screen";
        "Alt+Print" = action "screenshot-window";
        "Mod+Shift+E" = action "quit";
        "Mod+Shift+P" = action "power-off-monitors";
      };
  };
}
