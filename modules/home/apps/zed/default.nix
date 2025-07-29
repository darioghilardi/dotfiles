{
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots;
let
  cfg = config.dariodots.apps.zed;
in
{
  # Zed configuration (zed installed through brew for now)

  options.dariodots.apps.zed = with types; {
    enable = mkBoolOpt false "Whether or not to enable `Zed` configurations.";
  };

  config = mkIf cfg.enable {
    # Still experimenting, config to be moved here when it's stable enough.
    # home.file.".config/zed/settings.json".text = ''
    #   {
    #     "ui_font_size": 16,
    #     "buffer_font_size": 13,
    #     "tab_size": 2,
    #     "tab_bar": {
    #       "show": false
    #     },
    #     "toolbar": {
    #       "breadcrumbs": false,
    #       "quick_actions": false
    #     },
    #     "git": {
    #       "inline_blame": {
    #         "enabled": false
    #       }
    #     },
    #     "theme": {
    #       "mode": "dark",
    #       "dark": "One Dark"
    #     },
    #     "vim_mode": true
    #   }
    # '';

    # home.file.".config/zed/keymap.json".text = ''
    #   [
    #     {
    #       "context": "Editor && vim_mode == normal && (vim_operator == none || vim_operator == n) && !VimWaiting",
    #       "bindings": {
    #         "space f s": "workspace::Save",
    #         "space p t": "workspace::ToggleLeftDock",
    #         "space p f": "file_finder::Toggle",
    #         "space w v": "pane::SplitLeft",
    #         "space w s": "pane::SplitUp",
    #         "space w d": ["pane::CloseAllItems", { "close_pinned": false }],
    #         "space w h": ["workspace::ActivatePaneInDirection", "Left"],
    #         "space w l": ["workspace::ActivatePaneInDirection", "Right"],
    #         "space w k": ["workspace::ActivatePaneInDirection", "Up"],
    #         "space w j": ["workspace::ActivatePaneInDirection", "Down"],
    #         "space g b": "editor::ToggleGitBlame",
    #         "space t n": "workspace::ToggleBottomDock"
    #       }
    #     },
    #     {
    #       "context": "Editor && vim_mode == insert && (vim_operator == none || vim_operator == n) && !VimWaiting",
    #       "bindings": {
    #         "f d": ["vim::SwitchMode", "Normal"]
    #       }
    #     }
    #   ]
    # '';
  };
}
