{ ... }:
{
  # Trying to implement a whole local email processing pipeline here.
  # So far as I can tell I'm going to need
  # - mbsync: sync IMAPv4 -> Maildir
  # - notmuch: index Maildir for search
  # - afew: automatic tagging

  # NOTE: Must run `notmuch new` in this dir after setup, before use.
  accounts.email.maildirBasePath = "Mail";

  programs = {
    # Infrastructure
    lieer.enable = true;
    notmuch.enable = true;

    # MUAs/Mail Clients
    aerc.enable = true;
    # There is no password command, pulling with OAuth through lieer.
    aerc.extraConfig.general.unsafe-accounts-conf = true;
    #meli.enable = true;
    neomutt.enable = true;
  };

  services.lieer.enable = true;
  programs.neomutt = {
    vimKeys = true;
    unmailboxes = true;
    sidebar = {
      enable = true;
      shortPath = true;
      width = 20;
    };
    settings = {
      #nm_db_limit = "5000"; # Limits results in a query?
    };
    binds = [
      { map = ["index" "pager"]; key = "\\Cj"; action = "sidebar-next"; }
      { map = ["index" "pager"]; key = "\\Ck"; action = "sidebar-prev"; }
      { map = ["index" "pager"]; key = "\\Co"; action = "sidebar-open"; }
      { map = ["index" "pager"]; key = "B"; action = "sidebar-toggle-visible"; }
      { map = ["index" "pager"]; key = "R"; action = "reply"; }
      { map = ["index" "pager"]; key = "L"; action = "list-reply"; }
    ];
    macros = [
      { map = ["index" "pager"]; key = "ga"; action = "<modify-labels>-inbox -unread<enter>"; }
      { map = ["index" "pager"]; key = "gs"; action = "<modify-labels>+flagged -inbox<enter>"; }
      { map = ["index" "pager"]; key = "gd"; action = "<modify-labels>+trash -inbox -unread<enter>"; }
      { map = ["index" "pager"]; key = "ge"; action = "<modify-labels>+reading -inbox<enter>"; }
      { map = ["index" "pager"]; key = "gw"; action = "<modify-labels>+waiting -inbox<enter>"; }
      { map = ["index" "pager"]; key = "gr"; action = "<modify-labels>+reply -inbox<enter>"; }
      { map = ["index" "pager"]; key = "!"; action = "<modify-labels>+spam -inbox -unread<enter>"; }
    ];
    extraConfig = ''
      set send_charset="us-ascii:utf-8"

      # Date YMD
      set date_format="%y/%m/%d %I:%M%p";
      set index_format="%2C %Z %?X?A& ? %D %-15.15F %s (%-4.4c)"
      set rfc2047_parameters = yes
      set sleep_time = 0
      set markers = no
      set mark_old = no
      set wait_key = no
      set fast_reply
      set fcc_attach
      set forward_format = "Fwd: %s"
      set forward_quote
      set reverse_name
      set include
      set pager_stop = yes
      set abort_backspace = no

      set sidebar_next_new_wrap = yes
      set mail_check_stats
      set sidebar_format = '%D%?F? [%F]?%* %?N?%N/? %?S?%S?'

      set mime_forward = yes
      set mime_forward_rest = yes
      set mime_type_query_command = "file --mime-type -b %s"
      auto_view text/html
      auto_view application/pgp-encrypted
      auto_view application/msword
      auto_view application/vnd.openxmlformats-officedocument.wordprocessingml.document
      auto_view application/vnd.oasis.opendocument.text
      auto_view application/pdf
      unalternative_order *
      alternative_order text/enriched text/html text/plain
      set display_filter = "tac | sed '/\\\[-- Autoview/,+1d' | tac"

      set virtual_spoolfile
      set nm_unread_tag = "unread"
    '';
  };

  # TODO: Setup Microsoft and Apple Mail
  accounts.email.accounts = {
    "personal-gmail" = {
      flavor = "gmail.com";
      primary = true;
      address = "jay.m.looney@gmail.com";
      realName = "Jay";
      maildir.path = "personal-gmail";

      # NOTE: lieer is an OAuth API based thingy for Gmail
      lieer = {
        enable = true;
        sync = {
          enable = true;
          frequency = "hourly";
        };
      };
      notmuch.enable = true;
      notmuch.neomutt.enable = true;
      notmuch.neomutt.virtualMailboxes = [
        {
          name = "Inbox";
          query = "(tag:inbox -tag:social -tag:promotions -tag:updates) OR (tag:inbox and tag:flagged)";
        }
        {
          name = "Starred";
          query = "tag:flagged";
        }
        {
          name = "Waiting";
          query = "tag:waiting AND NOT tag:archive";
        }
        {
          name = "Noise";
          query = "tag:promotions OR tag:social OR tag:updates";
        }
        {
          name = "Sent";
          query = "tag:sent";
        }
        {
          name = "Drafts";
          query = "tag:draft";
        }
        {
          name = "Spam";
          query = "tag:spam";
        }
        {
          name = "Trash";
          query = "tag:trash";
        }
        {
          name = "Archives";
          query = "not tag:inbox and not tag:spam and not tag:trash";
        }
        {
          name = "All Mail";
          query = "*";
        }
      ];
      aerc.enable = true;
      #meli.enable = true;
      neomutt.enable = true;
      neomutt.extraConfig = ''
        unset spoolfile
        set spoolfile = "Inbox"
      '';
    };
  };
}
