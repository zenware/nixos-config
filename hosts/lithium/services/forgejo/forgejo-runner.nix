{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.zw.homelab.software-forge;
  homelabDomain = config.zw.homelab.domain;
in
{
  config = lib.mkIf (cfg.enable && cfg.cicd.enable) {
    assertions = [
      {
        assertion = cfg.secretsAreAvailable != null;
        message = "zw.homelab.software-forge.secretsAreAvailable must be set when cicd is enabled.";
      }
    ];

    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances.lithium = {
        enable = true;
        name = "${config.networking.hostName}-runner";
        url = "https://git.${homelabDomain}";
        # NOTE: Cannot make a token properly without secrets like sops-nix.
        tokenFile = lib.mkIf (cfg.secretsAreAvailable) cfg.tokenFile;
        labels = [
          "ubuntu-latest:docker://node:22-bookworm-slim"
          "ubuntu-22.04:docker://node:22-bookworm-slim"
        ];
      };
    };
  };
}
