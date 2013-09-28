#!/bin/bash

git submodule update --init

ROOT="$( cd -P "$( dirname "$0" )" && pwd )"

# vim/gvim configuration
rm -rf ~/.vim
rm ~/.vimrc
rm ~/.gvimrc
ln -s "$ROOT/vim/.vimrc" ~/.vimrc
ln -s "$ROOT/vim/.gvimrc" ~/.gvimrc
ln -s "$ROOT/vim" ~/.vim

# SSH configuration
if [ ! -d ~/.ssh ]; then
	mkdir ~/.ssh
	chmod 0700 ~/.ssh
fi
rm -f ~/.ssh/config
ln -s "$ROOT/ssh_config" ~/.ssh/config

# gem configuration
rm ~/.gemrc
ln -s "$ROOT/.gemrc" ~/

# i3 configuration
rm -rf ~/.i3
rm -rf ~/.i3status.conf
ln -s "$ROOT/.i3" ~/.i3
ln -s "$ROOT/.i3status.conf" ~/

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
