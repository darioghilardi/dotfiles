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
  home.packages = with pkgs; [
    bandwhich # display current network utilization by process

    du-dust # fancy version of `du`
    fd # fancy version of `find`
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

    # Dev tools
    kubeseal
    docker-compose
    colordiff
    mkcert
    autoconf
    automake
    # wxmac
    gettext
    pcre
    gnugrep
    bfg-repo-cleaner
    zstd
    gitu

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
    nil
    devenv
    nh

    # Code
    nodejs

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
    argo
  ];
}
