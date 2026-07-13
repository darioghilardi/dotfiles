_inputs: _final: prev: {
  direnv = prev.direnv.overrideAttrs (_oldAttrs: {
    doCheck = false;
  });
}
