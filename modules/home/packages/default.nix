{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.
  # All other arguments come from the module system.
  config,
  ...
}: {
  # Bat, a substitute for cat.
  # https://github.com/sharkdp/bat
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.bat.enable
  programs.bat.enable = true;
  programs.bat.config = {style = "plain";};

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
    awscli2
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
