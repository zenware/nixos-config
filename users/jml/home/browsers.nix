{ config, ... }:
{
  programs.nyxt.enable = true;
  programs.firefox = {
    configPath = "${config.xdg.configHome}/mozilla/firefox";
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

}
