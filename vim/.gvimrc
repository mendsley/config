source ~/.vimrc

" Set default gui-font to 
if has("win32") || has("win64")
	set guifont=Droid_Sans_Mono:h8
else
	set guifont=Droid\ Sans\ Mono\ 10
end

set guioptions+=c
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R
set guioptions-=b
