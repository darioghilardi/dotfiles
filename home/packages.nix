{ config, lib, pkgs, ... }:

{
  # Bat, a substitute for cat.
  # https://github.com/sharkdp/bat
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.bat.enable
  programs.bat.enable = true;
  programs.bat.config = { style = "plain"; };

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  # Zoxide, a faster way to navigate the filesystem
  # https://github.com/ajeetdsouza/zoxide
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.zoxide.enable
  programs.zoxide.enable = true;

  # tmux
  programs.tmux.enable = true;
  programs.tmux.keyMode = "vi";
  programs.tmux.prefix = "C-b";
  programs.tmux.tmuxinator.enable = true;

  # neovim
  programs.neovim.enable = true;

  home.packages = with pkgs; [
    bandwhich # display current network utilization by process
    bottom # fancy version of `top` with ASCII graphs
    du-dust # fancy version of `du`
    exa # fancy version of `ls`
    fd # fancy version of `find`
    htop # fancy version of `top`
    mosh # wrapper for `ssh` that better and not dropping connections
    procs # fancy version of `ps`
    unzip
    wget
    curl
    httpie
    tree
    gnupg
    gnugrep

    # Search tools
    silver-searcher
    ack
    ripgrep
    fzf

    # Dev tools
    docker-compose
    jq # json parser
    colordiff
    mkcert
    autoconf
    automake
    wxmac
    gettext
    azure-cli
    direnv
    pcre
    gnugrep

    # Elixir, to be able to run mix commands when not in a project
    beam.interpreters.erlangR24
    beam.packages.erlangR24.elixir_1_13
    beam.packages.erlangR24.hex
    beam.packages.erlangR24.rebar3

    # Nix
    statix # lints and suggestions for the Nix programming language
    nixfmt
    nix-prefetch-git

    # Code
    heroku
    awscli2
    nodejs-14_x
    earthly

    # Neovim
    elixir_ls
    sumneko-lua-language-server

    # Media
    imagemagick
    libwebp
    brotli
    ffmpeg

    # Kubernetes
    kubectl
    kubectx
    kustomize
    kubernetes-helm
    helmfile
    k9s
    argo
  ];
}
