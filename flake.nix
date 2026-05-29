{
  description = "Set of function to create a vims dervation setup with my common configuration";
  outputs = { self, nixpkgs }:
  let system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system;};
  fsac = pkgs.callPackage ./fsac.nix {};
  in

  { 
    createNeovide = import ./neovide.nix; 
    createNvim = import ./nvim.nix; 
    packages.x86_64-linux.default = pkgs.writeShellScriptBin "hi" ''echo "Brock is the man!!!"'';
    packages.x86_64-linux.fsautocomplete = fsac.fsautocomplete;
    packages.x86_64-linux.fsautocomplete-local-or-nix = fsac.fsautocomplete-local-or-nix;
  };
}
