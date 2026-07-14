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
      # saturn enables every nixos aspect (all the backup/service features).
      nixosAspects = builtins.attrValues (config.flake.modules.nixos or {});
      homeAspects = map (n: config.flake.modules.homeManager.${n}) [
        "bat" "bottom" "direnv" "eza" "fish" "fzf" "git" "htop" "jq" "k9s"
        "neovim" "packages" "ripgrep" "starship" "zoxide"
      ];
    };
}
