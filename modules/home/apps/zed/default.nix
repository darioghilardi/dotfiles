{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.apps.zed;
in {
  # Zed configuration (zed installed through brew for now)

  options.dariodots.apps.zed = with types; {
    enable = mkBoolOpt false "Whether or not to enable `Zed` configurations.";
  };

  config = mkIf cfg.enable {
    home.file.".config/zed/settings.json".text = ''
      {
        "ui_font_size": 16,
        "buffer_font_size": 14,
        "tab_size": 2,
        "vim_mode": true,
        "toolbar": {
          "breadcrumbs": false,
          "quick_actions": false
        },
        "git": {
          "inline_blame": {
            "enabled": false
          }
        }
      }
    '';

    home.file.".config/zed/keymap.json".text = ''
      [
        {
          "context": "Editor && vim_mode == normal && (vim_operator == none || vim_operator == n) && !VimWaiting",
          "bindings": {
            "space f s": "workspace::Save",
            "space p t": "workspace::ToggleLeftDock",
            "space p f": "file_finder::Toggle",
            "space s p": "project_panel::NewSearchInDirectory",
            "space w v": "pane::SplitLeft",
            "space w s": "pane::SplitUp",
            "space w d": ["pane::CloseActiveItem", { "saveIntent": "skip" }],
            "space w h": ["workspace::ActivatePaneInDirection", "Left"],
            "space w l": ["workspace::ActivatePaneInDirection", "Right"],
            "space w k": ["workspace::ActivatePaneInDirection", "Up"],
            "space w j": ["workspace::ActivatePaneInDirection", "Down"],
            "space g b": "editor::ToggleGitBlame"
          }
        },
        {
          "context": "Editor && vim_mode == insert && (vim_operator == none || vim_operator == n) && !VimWaiting",
          "bindings": {
            "f d": ["vim::SwitchMode", "Normal"]
          }
        }
      ]
    '';
  };
}
