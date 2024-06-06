{
  description = "Set of function to create a vims dervation setup with my common configuration";
  outputs = _: { 
    createNeovide = import ./neovide.nix; 
    createNvim = import ./nvim.nix; 

  };
}
