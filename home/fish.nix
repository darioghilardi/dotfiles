{ config, lib, pkgs, ... }:

{
  programs.fish.enable = true;

  programs.fish.plugins = [
    # This plugin is needed when using fish on macos to pickup ~/.nix-profile/bin
    {
      name = "nix-env";
      src = pkgs.fetchFromGitHub {
        owner = "lilyball";
        repo = "nix-env.fish";
        rev = "00c6cc762427efe08ac0bd0d1b1d12048d3ca727";
        sha256 = "1hrl22dd0aaszdanhvddvqz3aq40jp9zi2zn0v1hjnf7fx4bgpma";
      };
    }
    {
      name = "fzf.fish";
      src = pkgs.fetchFromGitHub {
        owner = "PatrickF1";
        repo = "fzf.fish";
        rev = "e246a4bb5fc61c1562178a62f4ff80685eb48565";
        sha256 = "023ilgp7hbqqsadjw58rd0zpmiy60gq55w96p38n7wv01p39cw3i";
      };
    }
  ];

  programs.fish.shellInit = ''
    # Fish syntax highlighting
    set -g fish_color_autosuggestion \'555\'  \'brblack\'
    set -g fish_color_cancel -r
    set -g fish_color_command --bold
    set -g fish_color_comment red
    set -g fish_color_cwd green
    set -g fish_color_cwd_root red
    set -g fish_color_end brmagenta
    set -g fish_color_error brred
    set -g fish_color_escape 'bryellow'  \'--bold\'
    set -g fish_color_history_current --bold
    set -g fish_color_host normal
    set -g fish_color_match --background=brblue
    set -g fish_color_normal normal
    set -g fish_color_operator bryellow
    set -g fish_color_param cyan
    set -g fish_color_quote yellow
    set -g fish_color_redirection brblue
    set -g fish_color_search_match \'bryellow\'  \'--background=brblack\'
    set -g fish_color_selection \'white\'  \'--bold\'  \'--background=brblack\'
    set -g fish_color_user brgreen
    set -g fish_color_valid_path --underline

    # Init startship
    starship init fish | source

    # Set editor
    set -gx EDITOR nvim

    # asdf
    source (brew --prefix asdf)/libexec/asdf.fish
    fish_add_path --path $HOME/.asdf/shims 
  '';

  programs.fish.functions = {
    # Toggles `$term_background` between "light" and "dark". Other Fish functions trigger when this
    # variable changes. We use a universal variable so that all instances of Fish have the same
    # value for the variable.
    toggle-background.body = ''
      if test "$term_background" = light
        set -U term_background dark
      else
        set -U term_background light
      end
    '';

    # Ask for confirmation when executing a command.
    read_confirm = ''
      while true
        read -l -P 'Do you want to continue? [y/N] ' confirm
        switch $confirm
          case Y y
            return 0
          case ''' N n
            return 1
        end
      end
    '';

    # Renames electronic invoices for the crappy BlueNext tool.
    invoice_rename = ''
      if read_confirm
        for j in ./*
          mv -v -- $j (uuidgen | string replace -a '-' ''')".xml"
        end
      end
    '';
  };

  programs.fish.interactiveShellInit = ''
    # Set Fish colors that aren't dependant the `$term_background`.
    set -g fish_color_quote        cyan      # color of commands
    set -g fish_color_redirection  brmagenta # color of IO redirections
    set -g fish_color_end          blue      # color of process separators like ';' and '&'
    set -g fish_color_error        red       # color of potential errors
    set -g fish_color_match        --reverse # color of highlighted matching parenthesis
    set -g fish_color_search_match --background=yellow
    set -g fish_color_selection    --reverse # color of selected text (vi mode)
    set -g fish_color_operator     green     # color of parameter expansion operators like '*' and '~'
    set -g fish_color_escape       red       # color of character escapes like '\n' and and '\x70'
    set -g fish_color_cancel       red       # color of the '^C' indicator on a canceled command
  '';

  programs.fish.shellAliases = {
    # Nix
    nfb = "cd ~/dotfiles; nix build .#darwinConfigurations.DarioBook.system";
    drs = "cd ~/dotfiles; darwin-rebuild switch --flake ~/dotfiles/";

    # General
    cat = "bat";
    du = "dust";
    ls = "exa";
    ll = "ls -l --time-style long-iso --icons";

    # Git
    gd = "git diff";
    gdc = "git diff --cached";
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gb = "git branch";
    gco = "git checkout";
    gl = "git log";
    gpush = "git push";
    gpull = "git pull";
    gbdate = "git branch --sort=-committerdate";
    gf = "git fetch";
    gm = "git merge";
    gum =
      "git checkout master && git fetch upstream && git merge upstream/master";

    # Tmuxinator
    tx = "tmuxinator";

    # Elixir
    i = "iex";
    ips = "iex -S mix phx.server";
    ism = "iex -S mix";
    m = "mix";
    mab = "mix archive.build";
    mai = "mix archive.install";
    mat = "mix app.tree";
    mc = "mix compile";
    mcf = "mix compile --force";
    mcv = "mix compile --verbose";
    mcl = "mix clean";
    mca = "mix do clean, deps.clean --all";
    mco = "mix coveralls";
    mcoh = "mix coveralls.html";
    mdoc = "mix docs";
    mdl = "mix dialyzer";
    mdlp = "mix dialyzer --plt";
    mcr = "mix credo";
    mcrs = "mix credo --strict";
    mcx = "mix compile.xref";
    mdc = "mix deps.compile";
    mdg = "mix deps.get";
    mdgc = "mix do deps.get, deps.compile";
    mdu = "mix deps.update";
    mdt = "mix deps.tree";
    mdua = "mix deps.update --all";
    mdun = "mix deps.unlock";
    mduu = "mix deps.unlock --unused";
    meb = "mix escript.build";
    mec = "mix ecto.create";
    mecm = "mix do ecto.create, ecto.migrate";
    med = "mix ecto.drop";
    mem = "mix ecto.migrate";
    megm = "mix ecto.gen.migration";
    merb = "mix ecto.rollback";
    mers = "mix ecto.reset";
    mes = "mix ecto.setup";
    mge = "mix gettext.extract";
    mgem = "mix gettext.extract --merge";
    mgm = "mix gettext.merge priv/gettext";
    mho = "mix hex.outdated";
    mlh = "mix local.hex";
    mn = "mix new";
    mns = "mix new --sup";
    mpd = "mix phx.digest";
    mpgc = "mix phx.gen.channel";
    mpgco = "mix phx.gen.context";
    mpgh = "mix phx.gen.html";
    mpgj = "mix phx.gen.json";
    mpgl = "mix phx.gen.live";
    mpgm = "mix phx.gen.model";
    mpgs = "mix phx.gen.secret";
    mpn = "mix phx.new";
    mpr = "mix phx.routes";
    mps = "mix phx.server";
    mr = "mix run";
    mrnh = "mix run --no-halt";
    mrl = "mix release";
    msn = "mix scenic.new";
    msne = "mix scenic.new.example";
    msnn = "mix scenic.new.nerves";
    msr = "mix scenic.run";
    mt = "mix test";
    mtc = "mix test --cover";
    mtf = "mix test --failed";
    mtmf = "mix test --max-failures";
    mts = "mix test --stale";
    mtw = "mix test.watch";
    mx = "mix xref";
    mf = "mix format";
    yup = "cd assets/ && yarn && cd ..";

    # Terraform
    tf = "terraform";

    # Helm
    hfd = "helmfile diff";
    hfa = "helmfile apply";

    # Kubernetes
    k = "kubectl";
    kd = "k describe";
    kg = "k get";
    kaf = "k apply -f";
    kdel = "k delete";
    ke = "k edit";
    kccc = "k config current-context";
    kcdc = "k config delete-context";
    kcsc = "k config set-context";
    kcuc = "k config use-context";
    kdd = "kd deployment";
    kdeld = "kdel deployment";
    kdeli = "kdel ingress";
    kdelp = "kdel pods";
    kdels = "kdel svc";
    kdelsec = "kdel secret";
    kdi = "kd ingress";
    kdp = "kd pods";
    kds = "kd svc";
    kdsec = "kd secret";
    ked = "ke deployment";
    kei = "ke ingress";
    kep = "ke pods";
    kes = "ke svc";
    keti = "k exec -ti";
    kgd = "kg deployment";
    kgi = "kg ingress";
    kgp = "kg pods";
    kgrs = "kg rs";
    kgs = "kg svc";
    kgsec = "kg secret";
    kl = "k logs";
    klf = "k logs -f";
    krh = "k rollout history";
    krsd = "k rollout status deployment";
    kru = "k rollout undo";
    ksd = "k scale deployment";
  };
}
