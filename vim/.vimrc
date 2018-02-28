" Matt's vim settings

" Use system TEMP directory for swap files
if has("win32") || has("win64")
    set directory=$TMP
else
    set directory=/tmp
end

let mapleader=";"

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
if has("win32") || has("win64")
	colorscheme wombat256
else
	colorscheme jellybeans
end

nnoremap <A-w><A-w> :wincmd w<CR>
nnoremap <A-W><A-W> :wincmd W<CR>

call pathogen#infect()
call pathogen#helptags()

nnoremap <leader>d :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>

set incsearch
set virtualedit=all

imap ,, <Esc>

" Map <leader><leader>w to <leader>w -- easymotion
map <leader>w <leader><leader>w
" Map <leader><leader>b to <leader>b -- easymotion
map <leader>b <leader><leader>b

" clang-vim options
let g:clang_cpp_options='-std=c++11'

let g:go_bin_path = expand("~/.gotools")
let g:go_fmt_path = "goimports"

" Utility to delete all inactive buffers
function! DeleteInactiveBufs()
    "From tabpagebuflist() help, get a list of all buffers in all tabs
    let tablist = []
    for i in range(tabpagenr('$'))
        call extend(tablist, tabpagebuflist(i + 1))
    endfor

    "Below originally inspired by Hara Krishna Dara and Keith Roberts
    "http://tech.groups.yahoo.com/group/vim/message/56425
    let nWipeouts = 0
    for i in range(1, bufnr('$'))
        if bufexists(i) && !getbufvar(i,"&mod") && index(tablist, i) == -1
        "bufno exists AND isn't modified AND isn't in the list of buffers open in windows and tabs
            silent exec 'bwipeout' i
            let nWipeouts = nWipeouts + 1
        endif
    endfor
    echomsg nWipeouts . ' buffer(s) wiped out'
endfunction
command! Bdi :call DeleteInactiveBufs()
