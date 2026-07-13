# Phase-A migration of saturn (x86_64-linux). Assembly lives in
# ../../lib/mkNixosHost.nix; this names the host and points at its reused files.
{inputs, ...}: {
  flake.nixosConfigurations.saturn =
    import ../../lib/mkNixosHost.nix {inherit inputs;} {
      hostName = "saturn";
      system = "x86_64-linux";
      systemModule = ../../reused/systems/x86_64-linux/saturn/default.nix;
      homeModule = ../../reused/saturn-home.nix;
    };
}
