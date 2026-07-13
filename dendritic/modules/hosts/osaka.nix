# Phase-A migration of osaka (aarch64-linux). Assembly lives in
# ../../lib/mkNixosHost.nix; this names the host and points at its reused files.
{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.osaka =
    import ../../lib/mkNixosHost.nix {inherit inputs;} {
      hostName = "osaka";
      system = "aarch64-linux";
      systemModule = ../../reused/systems/aarch64-linux/osaka/default.nix;
      homeModule = ../../reused/osaka-home.nix;
      nixosAspects = map (n: config.flake.modules.nixos.${n}) (import ../../lib/nixos-feature-order.nix);
      homeAspects = map (n: config.flake.modules.homeManager.${n}) (import ../../lib/home-feature-order.nix);
    };
}
