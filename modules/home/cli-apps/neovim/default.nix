{
  lib,
  inputs,
  config,
  pkgs,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.cli-apps.neovim;
  utils = inputs.nixCats.utils;
in {
  options.dariodots.cli-apps.neovim = with types; {
    enable = mkBoolOpt false "Whether or not to enable `neovim`.";
  };

  config = {
    nixCats = {
      enable = true;
      # this will add the overlays from ./overlays and also,
      # add any plugins in inputs named "plugins-pluginName" to pkgs.neovimPlugins
      # It will not apply to overall system, just nixCats.
      addOverlays = [
        (utils.standardPluginOverlay inputs)
      ];
      # NixCats allows the creation of multiple executable with different config.
      # This option lists them. Settings for each executable are defined below.
      # In this case just use nvim.
      packageNames = ["nvim"];

      luaPath = ./.;

      # the .replace vs .merge options are for modules based on existing configurations,
      # they refer to how multiple categoryDefinitions get merged together by the module.
      # for useage of this section, refer to :h nixCats.flake.outputs.categories
      categoryDefinitions.replace = {
        pkgs,
        settings,
        categories,
        extra,
        name,
        mkPlugin,
        ...
      } @ packageDef: {
        # to define and use a new category, simply add a new list to a set here,
        # and later, you will include categoryname = true; in the set you
        # provide when you build the package using this builder function.
        # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

        # lspsAndRuntimeDeps:
        # this section is for dependencies that should be available
        # at RUN TIME for plugins. Will be available to PATH within neovim terminal
        # this includes LSPs
        lspsAndRuntimeDeps = {
          general = with pkgs; [
            lazygit
          ];
          elixir = with pkgs;[
            elixir-ls
          ];
          lua = with pkgs; [
            lua-language-server
            stylua
          ];
          nix = with pkgs; [
            nixd
            alejandra
          ];
        };

        # This is for plugins that will load at startup without using packadd:
        startupPlugins = {
          general = with pkgs.vimPlugins; [
            lze
            lzextras
            plenary-nvim
            snacks-nvim
            onedark-nvim
            vim-sleuth
          ];
        };

        # not loaded automatically at startup.
        # use with packadd and an autocommand in config to achieve lazy loading
        optionalPlugins = {
          general = with pkgs.vimPlugins; [
            mini-nvim
            nvim-lspconfig
            vim-startuptime
            blink-cmp
            nvim-treesitter.withAllGrammars
            lualine-nvim
            lualine-lsp-progress
            gitsigns-nvim
            which-key-nvim
            nvim-lint
            conform-nvim
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
          ];
          lua = with pkgs.vimPlugins; [
            lazydev-nvim
          ];
          elixir = with pkgs.vimPlugins; [
            elixir-tools-nvim
          ];
        };

        # shared libraries to be added to LD_LIBRARY_PATH
        # variable available to nvim runtime
        sharedLibraries = {
          general = with pkgs; [];
        };

        # environmentVariables:
        # this section is for environmentVariables that should be available
        # at RUN TIME for plugins. Will be available to path within neovim terminal
        environmentVariables = {
          # test = {
          #   CATTESTVAR = "It worked!";
          # };
        };

        # categories of the function you would have passed to withPackages
        python3.libraries = {
          # test = [ (_:[]) ];
        };

        # If you know what these are, you can provide custom ones by category here.
        # If you dont, check this link out:
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
        extraWrapperArgs = {
          # test = [
          #   '' --set CATTESTVAR2 "It worked again!"''
          # ];
        };
      };

      # see :help nixCats.flake.outputs.packageDefinitions
      packageDefinitions.replace = {
        # These are the names of your packages
        # you can include as many as you wish.
        nvim = {
          pkgs,
          name,
          ...
        }: {
          # they contain a settings set defined above
          # see :help nixCats.flake.outputs.settings
          settings = {
            suffix-path = true;
            suffix-LD = true;
            wrapRc = true;
            # unwrappedCfgPath = "/path/to/here";
            # IMPORTANT:
            # your alias may not conflict with your other packages.
            aliases = ["vim"];
            # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
            hosts.python3.enable = true;
            hosts.node.enable = true;
          };
          # and a set of categories that you want
          # (and other information to pass to lua)
          categories = {
            general = true;
            elixir = true;
            lua = true;
            nix = true;
          };
          # anything else to pass and grab in lua with `nixCats.extra`
          extra = {
            nixdExtras.nixpkgs = ''import ${pkgs.path} {}'';
          };
        };
      };
    };
  };
}
