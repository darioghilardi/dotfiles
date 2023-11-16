{
  lib,
  pkgs,
  inputs,
  system,
  target,
  format,
  virtual,
  systems,
  config,
  ...
}: {
  # neovim
  home.packages = with pkgs; [
    bandwhich # display current network utilization by process
    bottom # fancy version of `top` with ASCII graphs
    du-dust # fancy version of `du`
    eza # fancy version of `ls`
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
    # wxmac
    gettext
    pcre
    gnugrep
    bfg-repo-cleaner

    # Elixir, to be able to run mix commands when not in a project
    # beam.interpreters.erlangR25
    # beam.packages.erlangR25.elixir_1_14
    # beam.packages.erlangR25.hex
    # beam.packages.erlangR25.rebar3

    # Nix
    statix # lints and suggestions for the Nix programming language
    alejandra
    nix-prefetch-git
    cachix

    # Code
    nodejs-18_x
    earthly

    # Neovim
    elixir_ls
    sumneko-lua-language-server

    # Media
    imagemagick
    libwebp
    brotli
    ffmpeg

    # Data recovery
    testdisk

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
