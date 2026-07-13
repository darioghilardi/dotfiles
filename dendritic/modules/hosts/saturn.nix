# Phase-A migration of saturn (x86_64-linux). Assembly lives in
# ../../lib/mkNixosHost.nix; this names the host and points at its reused files.
{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.saturn =
    import ../../lib/mkNixosHost.nix {inherit inputs;} {
      hostName = "saturn";
      system = "x86_64-linux";
      systemModule = ../../reused/systems/x86_64-linux/saturn/default.nix;
      homeModule = ../../reused/saturn-home.nix;
      nixosAspects = map (n: config.flake.modules.nixos.${n}) (import ../../lib/nixos-feature-order.nix);
      homeAspects = map (n: config.flake.modules.homeManager.${n}) (import ../../lib/home-feature-order.nix);
    };
}
