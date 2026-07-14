# Host entrypoint. Imported directly by flake.nix
# (imports = [ (import-tree ./modules) ./hosts ]), so it lives outside modules/
# and isn't walked by import-tree. Defines every darwin/nixos configuration by
# calling the builders in ../lib with each host's system/home files and the
# aspect modules it selects.
{
  config,
  inputs,
  ...
}: let
  mkDarwin = import ../lib/mkDarwinHost.nix {inherit inputs;};
  mkNixos = import ../lib/mkNixosHost.nix {inherit inputs;};

  # Darwin/nixos hosts take every aspect of their class, except where noted.
  # Home features are selected per host (order insignificant) via
  # `with config.flake.modules.homeManager; [ … ]` below.
  allDarwin = builtins.attrValues (config.flake.modules.darwin or {});
  allNixos = builtins.attrValues (config.flake.modules.nixos or {});
in {
  flake.darwinConfigurations = {
    DarioAir = mkDarwin {
      hostName = "DarioAir";
      systemModule = ./DarioAir/system.nix;
      homeModule = ./DarioAir/home.nix;
      darwinAspects = allDarwin;
      homeAspects = with config.flake.modules.homeManager; [
        bat bottom direnv eza fish fzf gh git htop jq k9s
        lazygit neovim packages ripgrep scriptDirectory ssh
        starship tmux wezterm zed zellij zoxide
      ];
    };

    DarioBook = mkDarwin {
      hostName = "DarioBook";
      systemModule = ./DarioBook/system.nix;
      homeModule = ./DarioBook/home.nix;
      darwinAspects = allDarwin;
      homeAspects = with config.flake.modules.homeManager; [
        bat direnv eza fish fzf gh git htop jq k9s
        lazygit neovim packages ripgrep scriptDirectory ssh
        starship tmux wezterm zed zellij zoxide
      ];
    };
  };

  flake.nixosConfigurations = {
    saturn = mkNixos {
      hostName = "saturn";
      system = "x86_64-linux";
      systemModule = ./saturn/system.nix;
      homeModule = ./saturn/home.nix;
      nixosAspects = allNixos; # every service/backup aspect
      homeAspects = with config.flake.modules.homeManager; [
        bat bottom direnv eza fish fzf git htop jq k9s
        neovim packages ripgrep starship zoxide
      ];
    };

    osaka = mkNixos {
      hostName = "osaka";
      system = "aarch64-linux";
      systemModule = ./osaka/system.nix;
      homeModule = ./osaka/home.nix;
      nixosAspects = [config.flake.modules.nixos.fish]; # only fish; not the saturn-only services
      homeAspects = with config.flake.modules.homeManager; [
        awscli bat bottom direnv eza fish fzf git htop jq
        neovim packages ripgrep starship tmux zoxide
      ];
    };
  };
}
