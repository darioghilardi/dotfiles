# Phase-A migration of DarioBook. All assembly lives in ../../lib/mkDarwinHost.nix;
# this just names the host and points at its reused system/home files.
{inputs, ...}: {
  flake.darwinConfigurations.DarioBook =
    import ../../lib/mkDarwinHost.nix {inherit inputs;} {
      hostName = "DarioBook";
      systemModule = ../../reused/DarioBook-system.nix;
      homeModule = ../../reused/DarioBook-home.nix;
    };
}
