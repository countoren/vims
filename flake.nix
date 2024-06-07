{
  description = "Set of function to create a vims dervation setup with my common configuration";
  outputs = { self, nixpkgs }:
  let system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system;};
  in

  { 
    createNeovide = import ./neovide.nix; 
    createNvim = import ./nvim.nix; 
    packages.x86_64-linux.default = pkgs.writeShellScriptBin "hi" ''echo "Brock is the man!!!"'';

  };
}
