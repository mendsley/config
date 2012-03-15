#!/bin/bash

ROOT="$( cd -P "$( dirname "$0" )" && pwd )"

# vim/gvim configuration
rm -rf ~/.vim
rm ~/.vimrc
rm ~/.gvimrc
ln -s "$ROOT/vim/.vimrc" ~/.vimrc
ln -s "$ROOT/vim/.gvimrc" ~/.gvimrc
ln -s "$ROOT/vim" ~/.vim

# git configuration
rm ~/.gitconfig
ln -s "$ROOT/.gitconfig" ~/.gitconfig

# fonts
if [ ! -d ~/.fonts ]; then
	mkdir ~/.fonts
fi
for f in $ROOT/fonts/*.ttf
do
	rm -f ~/.fonts/$(basename $f)
	ln -s $f ~/.fonts/$(basename $f)
done
fc-cache -f -v
