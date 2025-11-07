source ~/.vimrc

" Set default gui-font to 
if has("win32") || has("win64")
	set guifont=Essential\ PragmataPro:h10,Consolas:h10
else
	set guifont=Ubuntu\ Mono\ 12
end

set bg=light
colorscheme solarized
set guioptions+=c
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R
set guioptions-=b

set listchars=space:·,tab:»\ 
set list
