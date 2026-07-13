# neovim (nixCats). Special case: the module's `luaPath = ./.` bundles its whole
# directory (init.lua + lua/ + default.nix) into the nixCats config hash, so to
# stay byte-identical the aspect wraps the reused module in place rather than
# inlining it (moving the file would change luaPath's hash). The reused dir under
# ../../reused/home/cli-apps/neovim therefore stays as neovim's config source.
{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (final: _prev: {
    dariodots = import ../../lib/dariodots {lib = final;};
  });
in {
  flake.modules.homeManager."neovim" = {
    config,
    pkgs,
    ...
  }:
    import ../../reused/home/cli-apps/neovim/default.nix {
      inherit config pkgs inputs lib;
    };
}
