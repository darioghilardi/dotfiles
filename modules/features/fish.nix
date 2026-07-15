{...}: let
  # Shell aliases, grouped by domain then merged into one attrset. No keys are
  # shared between groups, so the merge is order-independent and equivalent to
  # defining them all inline.
  aliases = let
    nix = {
      flakeup = "nix flake update ~/dotfiles";
      nixclean = "sudo nh clean all --ask && nix store optimise";
    };

    editor = {
      vim = "nvim";
      vi = "nvim";
    };

    general = {
      cat = "bat";
      du = "dust";
      ls = "eza";
    };

    git = {
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
      gum = "git checkout master && git fetch upstream && git merge upstream/master";
      gom = "git checkout master && git fetch origin && git merge origin/master";
    };

    tmux = {
      mux = "tmuxinator";
    };

    elixir = {
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
      yup = "cd assets/ && npm install && cd ..";
    };

    terraform = {
      tf = "tofu";
    };

    helm = {
      hfd = "helmfile diff";
      hfa = "helmfile apply";
    };

    kubernetes = {
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
  in
    nix // editor // general // git // tmux // elixir // terraform // helm // kubernetes;
in {
  # System-level fish for the darwin hosts. Registers fish as a valid login
  # shell and applies the nix-darwin PATH fix; the interactive user config lives
  # in the homeManager module below. Both reference the same pkgs.fish store path
  # via useGlobalPkgs, so this is not a duplicate install.
  flake.modules.darwin.fish = {
    config,
    pkgs,
    ...
  }: {
    # Add shells installed by nix to /etc/shells file
    environment.shells = with pkgs; [bashInteractive fish zsh];
    environment.variables.SHELL = "${pkgs.fish}/bin/fish";

    # Make Fish the default shell
    programs.fish = {
      enable = true;
      useBabelfish = true;
      babelfishPackage = pkgs.babelfish;
      # Needed to address bug where $PATH is not properly set for fish:
      # https://github.com/LnL7/nix-darwin/issues/122
      shellInit = ''
        for p in (string split : ${config.environment.systemPath})
          if not contains $p $fish_user_paths
            set -g fish_user_paths $fish_user_paths $p
          end
        end
      '';
    };
  };

  # System-level fish for the NixOS hosts.
  flake.modules.nixos.fish = {
    programs.fish.enable = true;
  };

  # The interactive user config (aliases, plugins, prompt, colors).
  flake.modules.homeManager.fish = {
    config,
    pkgs,
    ...
  }: {
    programs.fish = {
      enable = true;
      generateCompletions = false;
      shellAliases = aliases;

      plugins = [
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

      shellInit = ''
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

        # Set sd root
        set -gx SD_ROOT "${config.home.homeDirectory}/dotfiles/scripts";
      '';

      interactiveShellInit = ''
        # Set Fish colors.
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
    };
  };
}
