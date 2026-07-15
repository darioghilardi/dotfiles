# git. Unconditional (imported by hosts that want it). The identity was the
# dariodots.user default (no host overrode it), so it's inlined here.
{ ... }: {
  flake.modules.homeManager."git" = { ... }: {
    programs.git = {
      enable = true;

      ignores = [ ".DS_Store" ];

      settings = {
        user = {
          name = "Dario Ghilardi";
          email = "darioghilardi@webrain.it";
        };

        extraConfig = {
          color.ui = "auto";
          init = {
            defaultBranch = "master";
          };
          core.editor = "code --wait";
        };

        # Enhanced diffs
        delta.enable = true;
      };
    };
  };
}
