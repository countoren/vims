{ pkgs ? import <nixpkgs> {}
, pkgsPath
, additionalVimrc 
, additionalPlugins
}:
import ./nvim.nix { inherit pkgs; 
  additionalVimrc = ''
    let $PATH = $PATH.":${pkgs.quick-lint-js}/bin"
    let $PATH = $PATH.":${pkgs.gopls}/bin"
    let $PATH = $PATH.":${pkgs.go}/bin"
  '' + additionalVimrc;
  additionalPlugins = with pkgs.vimPlugins; [
    vim-go
    vim-python-pep8-indent
    (pkgs.vimUtils.buildVimPlugin {
      name = "quick-lint-js";
      src = ''${pkgs.fetchzip {
        url = "https://c.quick-lint-js.com/releases/2.13.0/vim/quick-lint-js-vim.zip";
        sha256 = "obeNmt9SsTvs7ewlg3ISiW/wCYYJCwAozVHa+3xSHyU=";
        stripRoot=false;
      }}/quick-lint-js.vim'';
    })
  ];
}
