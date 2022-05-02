{ lib, pkgs, ... }:

{
  home.packages = [
    # Utilities
    pkgs.htop
    pkgs.bat
    pkgs.jq
    pkgs.unzip
    pkgs.wget
    pkgs.curl
    pkgs.httpie
    pkgs.tree
    pkgs.fd
    pkgs.colordiff
    pkgs.mkcert
    pkgs.gnupg

    # Libs
    pkgs.autoconf
    pkgs.automake
    pkgs.wxmac
    pkgs.gettext

    # Search tools
    pkgs.silver-searcher
    pkgs.ack
    pkgs.ripgrep
    pkgs.fzf

    # Code tools
    pkgs.tmux
    pkgs.tmuxinator
    pkgs.heroku
    pkgs.awscli2
    pkgs.nodejs-14_x
    pkgs.earthly
    pkgs.jd
    pkgs.helix

    # Neovim
    pkgs.elixir_ls
    pkgs.sumneko-lua-language-server

    # images
    pkgs.imagemagick
    pkgs.libwebp
    pkgs.brotli

    # videos
    pkgs.ffmpeg

    # nix
    pkgs.nixfmt
    pkgs.nix-prefetch-git

    # kubernetes
    pkgs.kubectl
    pkgs.kubectx
    pkgs.kustomize
    pkgs.kubernetes-helm
    pkgs.helmfile
    pkgs.k9s
    pkgs.argo
  ];
}
