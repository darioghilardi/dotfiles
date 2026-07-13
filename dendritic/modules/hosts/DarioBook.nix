# Phase-A migration of DarioBook. All assembly lives in ../../lib/mkDarwinHost.nix;
# this just names the host and points at its reused system/home files.
{
  config,
  inputs,
  ...
}: {
  flake.darwinConfigurations.DarioBook =
    import ../../lib/mkDarwinHost.nix {inherit inputs;} {
      hostName = "DarioBook";
      systemModule = ../../reused/DarioBook-system.nix;
      homeModule = ../../reused/DarioBook-home.nix;
      darwinAspects = map (n: config.flake.modules.darwin.${n}) (import ../../lib/darwin-feature-order.nix);
      homeAspects = map (n: config.flake.modules.homeManager.${n}) (import ../../lib/home-feature-order.nix);
    };
}
