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
  # Starship Prompt
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.starship.enable
  programs.starship.enable = true;

  programs.starship.settings = {
    # See docs here: https://starship.rs/config/
    # Symbols config configured ./starship-symbols.nix.

    elixir = {disabled = true;};
    package = {disabled = true;};
    aws = {symbol = "";};
    nix_shell = {
      symbol = "❄ ️";
      format = "[$symbol]($style)";
    };

    line_break.disabled = true;
    add_newline = false;
    gcloud.disabled = true; # annoying to always have on
    hostname.style = "bold green"; # don't like the default
    memory_usage.disabled = true;
    username.style_user = "bold blue"; # don't like the default

    directory = {
      fish_style_pwd_dir_length = 1; # turn on fish directory truncation
      truncation_length = 2; # number of directories not to truncate
    };
  };
}
