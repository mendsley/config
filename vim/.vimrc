" Matt's vim settings

" Use system TEMP directory for swap files
if has("win32") || has("win64")
    set directory=$TMP
else
    set directory=/tmp
end

" Use shell's slashes
set shellslash

" 60 lines
if has("win32") || has("win64")
    set lines=60
    set columns=125
end

" Backspace from anywhere in insert mode
set bs=2

" Syntax highlighting
syntax on
set bg=light

" 4 space auto-indent
set cindent shiftwidth=4

" Tab=4 spaces
set tabstop=4

" Enable line numbers
set number

" Mark characters past column 80
" match Todo '\%81v.*'

" enable the x,y rules
set ruler

" Ctrl-Space to auto-complete
map <C-Space> <C-n>
map! <C-Space> <C-n>

" Disable visual bell
set vb t_vb=

" Unix line endings
set ff=unix

set guioptions-=m
set guioptions-=T
colorscheme mywombat

nnoremap <A-w><A-w> :wincmd w<CR>
nnoremap <A-W><A-W> :wincmd W<CR>

call pathogen#infect()
call pathogen#helptags()

nnoremap <leader>d :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>

set incsearch
