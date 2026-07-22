{ inputs, ... }:
{
  perSystem =
    { ... }:
    {
      topology.modules = [
        ../../topology
        {
          nixosConfigurations = inputs.nixpkgs.lib.filterAttrs (
            name: _: name != "installIso"
          ) inputs.self.nixosConfigurations;
        }
      ];
    };
}
