# DarioBook host. All assembly lives in ../../lib/mkDarwinHost.nix; this just
# names the host and points at its system/home files under ../../hosts/DarioBook.
{
  config,
  inputs,
  ...
}: {
  flake.darwinConfigurations.DarioBook =
    import ../../lib/mkDarwinHost.nix {inherit inputs;} {
      hostName = "DarioBook";
      systemModule = ../../hosts/DarioBook/system.nix;
      homeModule = ../../hosts/DarioBook/home.nix;
      darwinAspects = builtins.attrValues (config.flake.modules.darwin or {});
      homeAspects = map (n: config.flake.modules.homeManager.${n}) [
        "bat" "direnv" "eza" "fish" "fzf" "gh" "git" "htop" "jq" "k9s"
        "lazygit" "neovim" "packages" "ripgrep" "script-directory" "ssh"
        "starship" "tmux" "wezterm" "zed" "zellij" "zoxide"
      ];
    };
}
