# saturn host (x86_64-linux). Assembly lives in ../../lib/mkNixosHost.nix; this
# names the host and points at its files under ../../hosts/saturn.
{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.saturn =
    import ../../lib/mkNixosHost.nix {inherit inputs;} {
      hostName = "saturn";
      system = "x86_64-linux";
      systemModule = ../../hosts/saturn/system.nix;
      homeModule = ../../hosts/saturn/home.nix;
      nixosAspects =
        map (n: config.flake.modules.nixos.${n}) (import ../../lib/nixos-feature-order.nix)
        ++ [config.flake.modules.nixos.fish];
      homeAspects = map (n: config.flake.modules.homeManager.${n}) [
        "git" "direnv" "packages" "zoxide" "starship" "ripgrep" "neovim" "k9s"
        "jq" "htop" "fzf" "fish" "eza" "bottom" "bat"
      ];
    };
}
