{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.zw.forgejo-runner;
  homelabDomain = config.zw.homelab.domain;
in
{
  options.zw.forgejo-runner = {
    enable = lib.mkEnableOption "the Forgejo Actions runner";

    tokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "File containing the Forgejo runner registration token.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tokenFile != null;
        message = "zw.forgejo-runner.tokenFile must be set when the Forgejo runner is enabled.";
      }
    ];

    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances.lithium = {
        enable = true;
        name = "${config.networking.hostName}-runner";
        url = "https://git.${homelabDomain}";
        tokenFile = cfg.tokenFile;
        labels = [
          "ubuntu-latest:docker://node:22-bookworm-slim"
          "ubuntu-22.04:docker://node:22-bookworm-slim"
        ];
      };
    };
  };
}
