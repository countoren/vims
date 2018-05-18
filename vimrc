" IMPORTANT: win32 users will need to have 'shellslash' set so that latex
" can be called correctly.
set shellslash

" IMPORTANT: grep will sometimes skip displaying the file name if you
" search in a singe file. This will confuse Latex-Suite. Set your grep
" program to always generate a file-name.
set grepprg=grep\ -nH\ $*


" OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults to
" 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
" The following changes the default filetype back to 'tex':
let g:tex_flavor='latex'

" /*** CtrlP ***/
let g:ctrlp_custom_ignore = 'node_modules'

" /*** Vim Interface  ***/

set wildmenu
set ignorecase
set hls
set number
set ruler
set showmatch
set ls=2
set iskeyword+=_,$,@,%,#  
set foldmethod=marker
set backspace=2
set nocompatible

set cf  " Enable error files & error jumping.
set clipboard+=unnamed  " Yanks go on clipboard instead.
set history=256  " Number of things to remember in history.
set autowrite  " Writes on make/shell commands
set timeoutlen=250  " Time to wait after ESC (default causes an annoying delay)
" colorscheme vividchalk  " Uncomment this to set a default theme

let &t_SI.="\e[5 q"
let &t_SR.="\e[4 q"
let &t_EI.="\e[1 q"

"adding more history (default 20)
set history=1000
	
"Formatting

" set smartindent
set tabstop=2
set softtabstop=2
set shiftwidth=2
" set expandtab "ignoring tabs putting spaces raplacing tabs

""colorscheme
colorscheme wombat

" /*** NERDTree Config ***/

if $CurrentSystem == 'WorkMac'
" autocmd VimEnter * NERDTree /private/tmp/
" autocmd VimEnter * /[ ][0-9]\+
" autocmd VimEnter * let VmID = expand("<cword>")
" autocmd VimEnter * let WindowsC =  "/private/tmp/".VmID."/C/"
" autocmd VimEnter * wincmd p
" autocmd VimEnter * NERDTreeToggle
endif
	
nmap <silent> <leader>v :NERDTree $VIMFolder<CR>
nmap <silent> <leader>vb :NERDTree $VIMFolder/bundle<CR>
nmap <silent> <leader>c :NERDTreeToggle .<CR>
nmap <silent> <leader>n :NERDTreeToggle<CR>

"Command line map
nnoremap ; :

" If I forgot to sudo a file, do that with :w!!
cmap w!! %!sudo tee > /dev/null %
command! SudoW exec 'w !sudo tee %'

" file types

exec 'au FileType tex so '.$VIMFolder.'bundle/ftplugin/tex_latexSuite.vim'


" autocomplete sortcut
inoremap <C-Space> <C-x><C-o>
inoremap <C-]> <C-x><C-]>

 "Window faster moves
 nnoremap <C-j> <C-w><C-j>
 map <C-k> <C-w><C-k>
 map <C-h> <C-w><C-h>
 map <C-l> <C-w><C-l>

 " set terminal to interactive
set shellcmdflag=-ic
			
 "Open Terminal
 
if $CurrentSystem == 'WorkMac'
	let $terminalWindow = '{1280, 0, 2560,1440}'
else
	let $terminalWindow = '{710, 0, 1300,900}'
endif

command! -nargs=* Terminal silent exec '!osascript
			\ -e "tell application \"Terminal\" to do script \"cd '''.getcwd().'''; <args>\"" 
			\ -e "tell application \"Terminal\" to set bounds of window 1 to  '.$terminalWindow.'" 
			\ -e "tell application \"Terminal\" to activate" 
			\ > /dev/null'

command! -nargs=* TerminalBoot2Docker silent exec '!osascript
			\ -e "tell application \"Terminal\" to do script \"boot2docker ssh\"" 
			\ -e "tell application \"Terminal\" to do script \"cd '''.getcwd().'''; <args>\" in window 1"
			\ -e "tell application \"Terminal\" to set bounds of window 1 to  '.$terminalWindow.'" 
			\ -e "tell application \"Terminal\" to activate" 
			\ > /dev/null'

command! -nargs=* TerminalFocus silent exec '!osascript
			\ -e "tell application \"Terminal\" to activate" 
			\ -e "tell application \"Terminal\" to do script \"<args>\" in window 1" 
			\ > /dev/null'

command! -nargs=* TerminalLeft silent exec '!osascript
			\ -e "tell application \"Terminal\" to do script \"cd '''.getcwd().'''; <args>\"" 
			\ -e "tell application \"Terminal\" to set bounds of window 1 to  '.$terminalWindow.'" 
			\ -e "tell application \"Terminal\" to set position of window 1 to {0,0}" 
			\ -e "tell application \"Terminal\" to activate" 
			\ > /dev/null'

command! -nargs=* TerminalBack silent exec '!osascript
			\ -e "tell application \"Terminal\" to do script \"cd '''.getcwd().'''; <args>\"" 
			\ -e "tell application \"Terminal\" to set bounds of window 1 to  '.$terminalWindow.'" 
			\ > /dev/null'

command! -nargs=* TerminalVimBundle  silent exec 'Terminal cd '.$VIMFolder.'bundle; <args>'


 "Open Finder
command! Finder silent execute "!open %:h"
command! RFinder silent execute "!open ".getcwd()

"Open Chrome for the buffered file
command! Chrome silent exec "!open /Applications/Google\\ Chrome.app/ \"%\""

"VIMRC
command! Vimrc silent :tabe $MYVIMRC

" open Bashrc command
"
command! Bashrc silent :tabe ~/.bashrc
command! BashrcShared silent :tabe ~/Dropbox/dotfiles/bashrc-shared-settings


"Command with copy to clipboard
command! -nargs=* CWithCopy exec "redir @* | <args> | redir END"


"VimGrep command
"
command! -nargs=1 VimGrep execute 'vimgrep /<f-args>/ **/*.*'

" Grep command
"
command! -nargs=1 Grep execute 'grep -R "<f-args>" **/*'




