{
  flake.modules.nixos.llm-agents =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    {
      options.zw.llm-agents = {
        enable = lib.mkEnableOption "LLM agents and supporting Nix cache";
      };

      config = lib.mkIf config.zw.llm-agents.enable {
        nix.settings = {
          extra-substituters = [ "https://cache.numtide.com" ];
          extra-trusted-public-keys = [
            "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
          ];
        };

        environment.systemPackages = with inputs.llm-agents.packages.${pkgs.system}; [
          gemini-cli
        ];
      };
    };
}
