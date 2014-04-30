source ~/.vimrc

" Set default gui-font to 
if has("win32") || has("win64")
	set guifont=Ubuntu_Mono:h10
else
	set guifont=Ubuntu\ Mono\ 12
end

colorscheme jellybeans
set guioptions+=c
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R
set guioptions-=b
