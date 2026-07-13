# Phase-A migration of DarioAir. All assembly lives in ../../lib/mkDarwinHost.nix;
# this just names the host and points at its reused system/home files.
{inputs, ...}: {
  flake.darwinConfigurations.DarioAir =
    import ../../lib/mkDarwinHost.nix {inherit inputs;} {
      hostName = "DarioAir";
      systemModule = ../../reused/DarioAir-system.nix;
      homeModule = ../../reused/DarioAir-home.nix;
    };
}
