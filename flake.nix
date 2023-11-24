{
  description = "Set of function to create a vims dervation setup with my common configuration";
  outputs = _: { createVim = import ./neovide.nix; };
}
