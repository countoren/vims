{ pkgs ? import <nixpkgs>{}
, vifm ? pkgs.vifm
, pkgsPath ? toString  (import ../pkgsPath.nix)
, additionalPlugins? []
, additionalVimrc? "" 
}:
with pkgs;
let 
  insideVimVifm = pkgs.symlinkJoin {
    name = "vifm-wrapped";
    paths = [ vifm ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/vifm \
      --add-flags '-c "set vicmd=e"' \
      --add-flags '-c "set cpoptions=fs"' \
      --add-flags '-c "filev *.* ${pkgs.bat}/bin/bat --color always --wrap never --pager never %c -p"' \
      --add-flags '-c "filev */ ${pkgs.eza}/bin/eza --icons -T --color=always %c %q"' \
      --add-flags '--choose-dir -' \
      --add-flags ' .'
      #shorter the name for easy of use and remove conflicts
      mv $out/bin/vifm $out/bin/vf 
    '';
  }; 
  my_plugins = builtins.attrValues (import ./plugins.nix { inherit vimUtils fetchFromGitHub; });
in 
{
  customRC = ''
    let $MYVIMRC = '${pkgsPath}/vim/vimrc'
    let $VIMFolder = '${pkgsPath}/vim'
    let $MYPKGS = '${pkgsPath}'
    let $EDITOR = 'sp'
    let $PATH = "${insideVimVifm}/bin:".$PATH
    " needed wl-copy, might not be needed in future versions
    let $PATH = "${pkgs.wl-clipboard}/bin:".$PATH

    " VIM Shell
    set shell=${pkgs.zsh}/bin/zsh

    "Start terminal if not open in file
    autocmd VimEnter * if empty(bufname(''')) | cd $MYPKGS | endif
    autocmd VimEnter * if empty(bufname(''')) | exe "terminal" | endif
    autocmd BufEnter * let buf=bufname() | if isdirectory(buf) | exec 'terminal' | call feedkeys('icd '.buf."\<CR>") | endif

    let g:ctrlp_working_path_mode=""
    ''
    + (builtins.readFile ./vimrc) + ''
    "My Nix pkgs
    command! DPkgs silent :sp $MYPKGS
    "Vim folder
    command! DVim silent :sp $MYPKGS/vim
    "VIMRC
    command! FVimrc silent :sp $MYVIMRC

    ''
    + (if additionalVimrc == "" then "" else ''
    "Env Specific configuration:
    ''+ additionalVimrc);

    

    packages.myPackages = with pkgs.vimPlugins;
    {
      start = [

      # Style
      vim-colorschemes
      vim-airline
      vim-airline-themes

      # Errors showing 
      ale

      # Global Search
      ctrlp

      # Editing
      surround
      commentary
      supertab  # needed to integrate UltiSnips and YouCompleteMe
      vim-snippets  # snippet database
      vim-lastplace
      indentLine

      {
        plugin = nvim-lspconfig; 
  config =
  ## Global mappings.
  ''
    let $PATH = $PATH.":${pkgs.nixd}/bin"

    lua << EOF
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
    vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
      end,
    })
      require('lspconfig').nixd.setup{}
    EOF
  '';
      }

      # Nix 
      { 
        plugin = vim-nix;
        config = ''
          " additonal help to vim-nix with cli statix(vim-nix uses it)
          let $PATH = "${pkgs.statix}/bin:".$PATH
          " origin :echo expand("statix fix --dry-run % > /tmp/diff") | vert diffpatch /tmp/diff

          function! NIX_maps()
            nnoremap <leader>ns :!statix fix --dry-run % > /tmp/diff"<CR>:vert diffpatch /tmp/diff<CR>
            nnoremap <leader>nss :!statix fix %<CR>
          endfunction
          autocmd FileType nix call NIX_maps()

          " TODO : nix-dead find dead code plugin

        '';
      }


      # Shell commands helper and file managers
      vim-eunuch
      vifm-vim

      # Git
      fugitive
      gitgutter

      # Misc
      # vimproc not sure if it is needed
      # vim-addon-mw-utils





      ] 
      ++ my_plugins 
      ++ additionalPlugins; 
    };
}
