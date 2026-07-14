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
      darwinAspects = builtins.attrValues (config.flake.modules.darwin or {});
      homeAspects = map (n: config.flake.modules.homeManager.${n}) [
        "bat" "bottom" "direnv" "eza" "fish" "fzf" "gh" "git" "htop" "jq" "k9s"
        "lazygit" "neovim" "packages" "ripgrep" "script-directory" "ssh"
        "starship" "tmux" "wezterm" "zed" "zellij" "zoxide"
      ];
    };
}
