# Home feature composition order — reverse of snowfall's alphabetical
# depth-first path traversal of modules/home (apps/*, cli-apps/*, packages,
# tools/*, user). Passing the home aspects in this order reproduces snowfall's
# merge order for order-sensitive options (home.packages list, fish init), so
# the toplevel stays byte-identical. (Phase-B scaffolding; see mkDarwinHost.)
[
  "user"
  "tmux"
  "ssh"
  "git"
  "direnv"
  "packages"
  "zoxide"
  "zellij"
  "starship"
  "script-directory"
  "ripgrep"
  "neovim"
  "lazygit"
  "k9s"
  "jq"
  "htop"
  "gh"
  "fzf"
  "fish"
  "eza"
  "bottom"
  "bat"
  "awscli"
  "zed"
  "wezterm"
  "kitty"
]
