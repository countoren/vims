{ pkgs ? import <nixpkgs> { }
, vifm ? pkgs.vifm
, pkgsPath ? toString (import ../pkgsPath.nix)
, additionalPlugins ? [ ]
, additionalVimrc ? ""
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
  '' + additionalVimrc);



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
        {
          plugin = ctrlp;
          config = ''
            let g:ctrlp_working_path_mode=""
            let g:ctrlp_show_hidden = 1
            let g:ctrlp_custom_ignore = 'node_modules'
            let g:ctrlp_user_command = [ '.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f' ]
          '';
        }

        # Editing
        surround
        commentary
        supertab # needed to integrate UltiSnips and YouCompleteMe
        vim-snippets # snippet database
        vim-lastplace
        indentLine
        #TODO: maybe need setup
        zen-mode-nvim

        # Markdown
        markdown-preview-nvim

        # Errors
        trouble-nvim

        #LSP
        {
          plugin = fidget-nvim;
          config = '' 
        lua << EOF
          require('fidget').setup {}
        EOF'';
        }
        #TODO: maybe need setup
        nvim-lint


        #TODO: setup
        {
          plugin = nvim-treesitter-textobjects;
          config = ''
            lua <<EOF
            require'nvim-treesitter.configs'.setup {
              textobjects = {
                select = {
                  enable = true,
                  keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["ac"] = "@class.outer",
                    ["ic"] = "@class.inner",        
                    ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
                  },
                },
                swap = {
                    enable = true,
                    swap_next = {
                      ["<leader>a"] = "@parameter.inner",
                    },
                    swap_previous = {
                      ["<leader>A"] = "@parameter.inner",
                    },
                  },
                  move = {
                  enable = true,
                  set_jumps = true, -- whether to set jumps in the jumplist
                  goto_next_start = {
                    ["]m"] = "@function.outer",
                    --
                    -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
                    ["]o"] = "@loop.*",
                    -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
                    --
                    -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
                    -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
                    ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                    ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
                  },
                  goto_next_end = {
                    ["]M"] = "@function.outer",
                  },
                  goto_previous_start = {
                    ["[m"] = "@function.outer",
                  },
                  goto_previous_end = {
                    ["[M"] = "@function.outer",
                  },


                  },
                },
              }


            EOF
          '';
        }



        {
          plugin = nvim-lspconfig;
          config =
            ## Global mappings.
            ''
              let $PATH = $PATH.":${pkgs.nixd}/bin"
              let g:indentLine_setConceal = 0 

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
                  vim.keymap.set('n', '<leader>k', vim.lsp.buf.signature_help, opts)
                  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
                  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
                  vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
                  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
                  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                  vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
                  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)
                end,
              })
                  require('lspconfig').nil_ls.setup {
                    autostart = true,
                    capabilities = caps,
                    cmd = { '${pkgs.nil}/bin/nil' },
                    settings = {
                      ['nil'] = {
                        testSetting = 42,
                        formatting = {
                          command = { "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" },
                        },
                      },
                    },
                  }
              EOF
            '';
        }

        # Nix 
        vim-nix
        # { 
        #   plugin = vim-nix;
        #   config = ''
        #     " additonal help to vim-nix with cli statix(vim-nix uses it)
        #     let $PATH = "${pkgs.statix}/bin:".$PATH
        #     " origin :echo expand("statix fix --dry-run % > /tmp/diff") | vert diffpatch /tmp/diff

        #     function! NIX_maps()
        #       nnoremap <leader>ns :!statix fix --dry-run % > /tmp/diff"<CR>:vert diffpatch /tmp/diff<CR>
        #       nnoremap <leader>nss :!statix fix %<CR>
        #     endfunction
        #     autocmd FileType nix call NIX_maps()

        #     " TODO : nix-dead find dead code plugin

        #   '';
        # }


        # Shell commands helper and file managers
        vim-eunuch
        vifm-vim

        # Git

        {
          plugin = gitsigns-nvim;
          config = ''
            nnoremap <leader>gm <cmd>lua require('gitsigns').blame_line(true)<cr>
            lua << EOF
              require('gitsigns').setup{
              current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
              current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
                delay = 100,
                ignore_whitespace = false,
              },
              current_line_blame_formatter = '<author>, <author_time:%d-%m-%Y> - <summary>',
            }

            local gs = package.loaded.gitsigns

            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation
            map('n', ']c', function()
              if vim.wo.diff then return ']c' end
              vim.schedule(function() gs.next_hunk() end)
              return '<Ignore>'
            end, {expr=true})

            map('n', '[c', function()
              if vim.wo.diff then return '[c' end
              vim.schedule(function() gs.prev_hunk() end)
              return '<Ignore>'
            end, {expr=true})

            -- Actions
            map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
            map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
            map('n', '<leader>hS', gs.stage_buffer)
            map('n', '<leader>hu', gs.undo_stage_hunk)
            map('n', '<leader>hR', gs.reset_buffer)
            map('n', '<leader>hp', gs.preview_hunk)
            map('n', '<leader>hb', function() gs.blame_line{full=true} end)
            map('n', '<leader>tb', gs.toggle_current_line_blame)
            map('n', '<leader>hd', gs.diffthis)
            map('n', '<leader>hD', function() gs.diffthis('~') end)
            map('n', '<leader>td', gs.toggle_deleted)

            -- Text object
            map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
            EOF
          '';
        }
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
