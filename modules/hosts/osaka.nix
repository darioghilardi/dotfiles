# osaka host (aarch64-linux). Assembly lives in ../../lib/mkNixosHost.nix; this
# names the host and points at its files under ../../hosts/osaka.
{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.osaka =
    import ../../lib/mkNixosHost.nix {inherit inputs;} {
      hostName = "osaka";
      system = "aarch64-linux";
      systemModule = ../../hosts/osaka/system.nix;
      homeModule = ../../hosts/osaka/home.nix;
      nixosAspects = [config.flake.modules.nixos.fish]; # no service aspects (saturn-only), just fish
      homeAspects = map (n: config.flake.modules.homeManager.${n}) [
        "tmux" "git" "direnv" "packages" "zoxide" "starship" "ripgrep" "neovim"
        "jq" "htop" "fzf" "fish" "eza" "bottom" "bat" "awscli"
      ];
    };
}
