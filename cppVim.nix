{ pkgs ? import <nixpkgs>{}
, pkgsPath ? "~/.nixpkgs"
, additionalPlugins? []
, additionalCustPlugins? {}
, additionalVimrc? "" 
}:
import ./linuxVim.nix {
  inherit pkgs;
  name = "cppVim";
  vimrcAndPlugins = import ./VimrcAndPlugins.nix { 
    inherit pkgsPath; 
    additionalPlugins = [
      "LanguageClient-neovim"
      "coc-clangd"
      "clang_complete"
      "coc-nvim"
      "fzf-vim"
      # "aspellDicts"
      "clang_complete"
    ];
    additionalCustPlugins = {
      LanguageClient-neovim = import ./LanguageClient.nix { inherit pkgs; };
      # aspellDicts = pkgs.aspellDicts.en;
      clang_complete = pkgs.vimPlugins.clang_complete;
    };
    additionalVimrc = ''
    " Language server key bindings
    function LC_maps()
    if has_key(g:LanguageClient_serverCommands, &filetype)
    nnoremap <F5> :call LanguageClient_contextMenu()<CR>
    nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
    nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
    nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
    command! Symbols :call LanguageClient_textDocument_documentSymbol()
    command! Fix :call LanguageClient_textDocument_codeAction()

              nnoremap <leader>ld :call LanguageClient#textDocument_definition()<CR>
              nnoremap <leader>lr :call LanguageClient#textDocument_rename()<CR>
              nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<CR>
              nnoremap <leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
              nnoremap <leader>lx :call LanguageClient#textDocument_references()<CR>
              nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<CR>
              nnoremap <leader>lc :call LanguageClient#textDocument_completion()<CR>
              nnoremap <leader>lh :call LanguageClient#textDocument_hover()<CR>
              nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<CR>
              nnoremap <leader>lm :call LanguageClient_contextMenu()<CR>
            endif
          endfunction
          autocmd FileType * call LC_maps()
    '';

  };
}
