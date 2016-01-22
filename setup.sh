#!/bin/bash

git submodule update --init

ROOT="$( cd -P "$( dirname "$0" )" && pwd )"

# vim/gvim configuration
rm -rf $HOME/.vim
rm $HOME/.vimrc
rm $HOME/.gvimrc
ln -s "$ROOT/vim/.vimrc" $HOME/.vimrc
ln -s "$ROOT/vim/.gvimrc" $HOME/.gvimrc
ln -s "$ROOT/vim" $HOME/.vim

# SSH configuration
if [ ! -d $HOME/.ssh ]; then
	mkdir $HOME/.ssh
	chmod 0700 $HOME/.ssh
fi
rm -f $HOME/.ssh/config
ln -s "$ROOT/ssh_config" $HOME/.ssh/config

# gem configuration
rm $HOME/.gemrc
ln -s "$ROOT/.gemrc" $HOME/

# i3 configuration
rm -rf $HOME/.i3
rm -rf $HOME/.i3status.conf
ln -s "$ROOT/.i3" $HOME/.i3
ln -s "$ROOT/.i3status.conf" $HOME/

# git configuration
rm $HOME/.gitconfig
ln -s "$ROOT/.gitconfig" $HOME/.gitconfig

# fonts
if [ ! -d $HOME/.fonts ]; then
	mkdir $HOME/.fonts
fi
for f in $ROOT/fonts/*.ttf
do
	rm -f $HOME/.fonts/$(basename $f)
	ln -s $f $HOME/.fonts/$(basename $f)
done
fc-cache -f -v
