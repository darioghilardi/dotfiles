{inputs, ...}: final: prev: {
  tmux = inputs.nixpgs-stable.packages.${prev.system}.tmux;
}
