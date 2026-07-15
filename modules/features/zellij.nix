{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake.modules.homeManager."zellij" =
    {
      config,
      pkgs,
      ...
    }:
    with lib;
    {
      programs.zellij = {
        enable = true;
        # This avoid zellij to autostarts on every new terminal.
        enableFishIntegration = false;
        settings = {
          theme = "solarized-dark";
          pane_frames = false;
        };
      };

      xdg.configFile."zellij/layouts" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/modules/home/cli-apps/zellij/layouts";
        recursive = true;
      };

    };
}
