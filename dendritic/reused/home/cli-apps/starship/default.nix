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

    elixir.disabled = true;
    gcloud.disabled = true; # annoying to always have on
    package.disabled = true;

    aws.symbol = "";

    add_newline = false;
    character = {
      success_symbol = "[➜](bold green)";
      error_symbol = "[✗](bold red)";
    };
    line_break.disabled = true;
    memory_usage.disabled = true;
    hostname.style = "bold green";
    username.style_user = "bold blue";

    nix_shell = {
      symbol = "❄ ️";
      format = "[$symbol]($style)";
    };

    directory = {
      fish_style_pwd_dir_length = 1; # turn on fish directory truncation
      truncation_length = 2; # number of directories not to truncate
    };
  };
}
