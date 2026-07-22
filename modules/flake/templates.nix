{ config, ... }:
{
  flake.templates = {
    secrets = {
      path = ../../templates/nixos-secrets;
      description = "Templates for secrets management. These should be copied and filled out with real values, then encrypted with SOPS or a similar tool.";
    };
  };
  flake.defaultTemplate = config.flake.templates.secrets;
}
