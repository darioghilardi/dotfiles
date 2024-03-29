{
  lib,
  pkgs,
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
