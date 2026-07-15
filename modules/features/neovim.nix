# neovim (nixCats). The module's `luaPath = ./.` bundles its whole directory
# (init.lua + lua/ + default.nix) into the nixCats config hash, so the aspect
# wraps the module in place rather than inlining it. The neovim config lives in
# its own tree at ../../neovim (kept intact so luaPath's hash stays stable).
{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib.extend (
    final: _prev: {
      dariodots = import ../../lib/opts { lib = final; };
    }
  );
in
{
  flake.modules.homeManager.neovim =
    {
      config,
      pkgs,
      ...
    }:
    import ../../neovim/default.nix {
      inherit
        config
        pkgs
        inputs
        lib
        ;
    };
}
