# DarioAir host. All assembly lives in ../../lib/mkDarwinHost.nix; this just
# names the host and points at its system/home files under ../../hosts/DarioAir.
{
  config,
  inputs,
  ...
}: {
  flake.darwinConfigurations.DarioAir =
    import ../../lib/mkDarwinHost.nix {inherit inputs;} {
      hostName = "DarioAir";
      systemModule = ../../hosts/DarioAir/system.nix;
      homeModule = ../../hosts/DarioAir/home.nix;
      darwinAspects = map (n: config.flake.modules.darwin.${n}) (import ../../lib/darwin-feature-order.nix);
      homeAspects = map (n: config.flake.modules.homeManager.${n}) [
        "tmux" "ssh" "git" "direnv" "packages" "zoxide" "zellij" "starship"
        "script-directory" "ripgrep" "neovim" "lazygit" "k9s" "jq" "htop" "gh"
        "fzf" "fish" "eza" "bottom" "bat" "zed" "wezterm"
      ];
    };
}
